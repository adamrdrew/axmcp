# Implementation Steps

## S001: Observer Event Types and Data Models

**Intent**: Define the domain types for observation events before building any infrastructure, establishing the data contracts that all subsequent steps depend on.

**Work**:
- Create `ObserverEventType` enum in `Observers/` with cases: valueChanged, focusChanged, windowCreated, windowDestroyed, titleChanged
  - Include `init(from axNotification: String)` to map AX notification names (kAXValueChangedNotification, etc.) to enum cases
  - Include `var axNotificationName: String` to map back to AX notification names
- Create `ObserverEvent` struct (Codable, Sendable) with fields: timestamp (ISO 8601 String), eventType (ObserverEventType), elementRole (String?), elementTitle (String?), elementPath (String?), newValue (String?)
- Create `ObserverError` enum (typed error) with cases: invalidApplication, observerCreationFailed, durationExceeded(max: Int), applicationTerminated, maxEventsExceeded, observerAlreadyActive(pid: pid_t)
- Write tests for: event type mapping from AX notification names, event Codable round-trip, ISO 8601 timestamp format

**Done when**:
- All observer domain types are defined with Codable and Sendable conformance
- AX notification name mapping is bidirectional and tested
- Tests verify serialization produces expected JSON structure

## S002: ObserveChanges Parameters and Response Structs

**Intent**: Define the MCP tool parameter and response types following the established handler pattern from Phase 4/5.

**Work**:
- Create `ObserveChangesParameters` struct (Codable) in `Observers/`: app (String), events (optional [String]), elementPath (optional String), duration (optional Int)
  - Add `validate() throws(ToolParameterError)` method: app required, duration clamped to 1-300s, event names validated against known types
  - Default duration to 30s when nil
  - Clamp duration to max 300s (not error — silently clamp with note in response)
- Create `ObserveChangesResponse` struct (Codable) in `Observers/`: events ([ObserverEvent]), totalEventsCollected (Int), eventsReturned (Int), truncated (Bool), durationRequested (Int), durationActual (Double), applicationTerminated (Bool), notes ([String])
- Write tests for: parameter validation, default duration, duration clamping, invalid event type rejection, response serialization

**Done when**:
- Parameters parse from JSON and validate correctly
- Response serializes to structured JSON with all required fields
- Duration clamping logic tested

## S003: AXBridge Observer Protocol Extension

**Intent**: Extend the AXBridge protocol with observer-related methods to maintain testability through protocol abstraction.

**Work**:
- Add observer methods to `AXBridge` protocol:
  - `func createObserver(for pid: pid_t, callback: @escaping AXObserverCallback, context: UnsafeMutableRawPointer?) throws(AccessibilityError) -> AXObserver`
  - `func addNotification(observer: AXObserver, element: UIElement, notification: String) throws(AccessibilityError)`
  - `func removeNotification(observer: AXObserver, element: UIElement, notification: String) throws(AccessibilityError)`
  - `func getObserverRunLoopSource(observer: AXObserver) -> CFRunLoopSource`
- Implement in LiveAXBridge (new extension file `LiveAXBridge+ObserverOperations.swift`):
  - Wrap AXObserverCreate, AXObserverAddNotification, AXObserverRemoveNotification, AXObserverGetRunLoopSource
- Update MockAXBridge with observer stubs:
  - Track registered notifications
  - Provide method to simulate event delivery for tests
- Write tests for: mock observer creation, notification registration tracking, simulated event delivery

**Done when**:
- AXBridge protocol includes observer methods
- LiveAXBridge wraps real AX observer APIs
- MockAXBridge supports observer testing with event simulation
- Tests verify mock observer behavior

## S004: ObserverManager Actor — Core Lifecycle

**Intent**: Build the central actor that manages AXObserver lifecycle: creation, notification registration, event collection, and cleanup.

**Work**:
- Create `ObserverManager` actor in `Observers/` directory
- Properties: activeSubscriptions dictionary keyed by a generated subscription ID
- Create `ObservationSubscription` struct: id (UUID), pid (pid_t), observer (AXObserver?), events ([ObserverEvent]), startTime (Date), maxDuration (TimeInterval), maxEvents (Int), continuation (AsyncStream<ObserverEvent>.Continuation?)
- Implement `startObservation(pid: pid_t, element: UIElement?, notifications: [String], duration: TimeInterval, bridge: any AXBridge) async throws(ObserverError) -> AsyncStream<ObserverEvent>`:
  - Create AXObserver via bridge
  - Set up AsyncStream with continuation
  - Register requested notifications
  - Add observer RunLoop source to a dedicated RunLoop
  - Return the stream for event consumption
- Implement `stopObservation(id: UUID) async`:
  - Remove notifications from observer
  - Remove RunLoop source
  - Finish the continuation
  - Remove from activeSubscriptions
- Implement `stopAll() async` for server shutdown cleanup
- Keep actor under 100 lines — extract helpers to extensions if needed
- Write tests for: start/stop lifecycle, subscription tracking, stopAll cleanup

**Done when**:
- ObserverManager creates and tracks observer subscriptions
- Subscriptions can be started and stopped cleanly
- stopAll cleans up all active subscriptions
- Tests verify lifecycle management

## S005: RunLoop Thread Management

**Intent**: Set up the dedicated RunLoop thread that AXObserver requires, bridging its callback-based model into Swift structured concurrency.

**Work**:
- Create `ObserverRunLoop` class (or struct with internal class for RunLoop ownership) in `Observers/`:
  - Manage a dedicated background thread running a CFRunLoop
  - Provide `addSource(_ source: CFRunLoopSource)` to add observer sources
  - Provide `removeSource(_ source: CFRunLoopSource)` to remove sources
  - Provide `stop()` to terminate the RunLoop thread
  - Thread must be started lazily on first use and stopped when no observers remain
- Implement the C callback function that bridges AXObserver events:
  - The callback receives element, notification name, and userData (context pointer)
  - Context pointer holds a reference to the continuation for yielding events
  - Callback extracts basic element info (role, title) and creates ObserverEvent
  - Yields event to the AsyncStream continuation
- Create `ObserverCallbackContext` class (reference type for pointer stability): holds the AsyncStream continuation and bridge reference for element info extraction
- Write tests for: RunLoop source add/remove, callback context memory management

**Done when**:
- Dedicated RunLoop thread starts and stops correctly
- C callback bridges events to AsyncStream continuation
- Context pointer management is safe (no dangling pointers)
- Tests verify source management

## S006: Duration Enforcement and Event Collection

**Intent**: Implement the time-bounded event collection logic that makes observe_changes return after a specified duration with all collected events.

**Work**:
- Create `EventCollector` struct in `Observers/`:
  - Implements the logic to consume an AsyncStream<ObserverEvent> for a given duration
  - Enforces max event count (default: 1000 events)
  - Returns collected events when: duration expires, max events reached, or stream terminates early (app quit)
  - Uses Task.sleep or withTimeout pattern for duration enforcement
- Implement `func collect(from stream: AsyncStream<ObserverEvent>, duration: TimeInterval, maxEvents: Int) async -> EventCollectionResult`
- Create `EventCollectionResult` struct: events ([ObserverEvent]), truncated (Bool), earlyTermination (Bool), actualDuration (TimeInterval)
- Application termination detection: periodically check if PID is still running, or listen for kAXUIElementDestroyedNotification on the app element
- Write tests for: collection within duration, max events truncation, early termination, empty observation (no events)

**Done when**:
- EventCollector respects duration limits
- Max event count prevents unbounded memory growth
- Early termination detected and handled gracefully
- Tests verify all collection scenarios

## S007: ObserveChangesHandler

**Intent**: Implement the observe_changes tool handler that ties together all observer components with the established handler pattern.

**Work**:
- Create `ObserveChangesHandler` struct in `Tools/` directory
- Inject dependencies: AppResolver, AXBridge, ObserverManager
- Execute flow:
  1. Validate parameters (app required, duration clamped)
  2. Resolve app to PID
  3. Optionally resolve element_path to live UIElement
  4. Map event type strings to AX notification names
  5. Start observation via ObserverManager
  6. Collect events via EventCollector for specified duration
  7. Stop observation and clean up
  8. Build and return ObserveChangesResponse
- Handle error cases with ErrorConverter pattern:
  - Invalid app, invalid element path, observer creation failure, application terminated
- Note: do NOT check read-only mode or blocklist (observation is read-only)
- Write tests for: success path, invalid app, invalid element path, duration enforcement, empty results

**Done when**:
- ObserveChangesHandler executes full observation flow
- Events collected and returned as structured response
- All error paths handled with structured errors
- Tests verify handler behavior with MockAXBridge

## S008: Wire observe_changes to MCP Server

**Intent**: Register the observe_changes tool with the MCP server and dispatch calls to the handler.

**Work**:
- Add `observe_changes` tool schema to AccessibilityServer tools list (in a new `observeTools()` method or added to readTools since it's read-only)
  - Tool always visible (not gated by read-only mode)
  - Schema includes: app (required string), events (optional array of strings), element_path (optional string), duration (optional number with description noting default 30s, max 300s)
- Add ObserverManager instance to ServerContext
- Add dispatch case in callTool for "observe_changes"
- Create `AccessibilityServer+ObserveTools.swift` extension for the handler dispatch logic
- Write tests for: tool appears in tool list in both normal and read-only modes, dispatch routes correctly

**Done when**:
- observe_changes appears in MCP tool list regardless of read-only mode
- Tool invocations route to ObserveChangesHandler
- ObserverManager lifecycle managed through ServerContext

## S009: ErrorConverter Updates for Observer Operations

**Intent**: Extend ErrorConverter to handle observer-specific error types.

**Work**:
- Add `convertObserverError(ObserverError, operation: String, app: String) -> ToolError` method
- Handle cases: invalidApplication, observerCreationFailed, durationExceeded, applicationTerminated, maxEventsExceeded
- All error responses include: operation ("observe_changes"), errorType, message, app, guidance
- Create `ErrorConverter+ObserverOperations.swift` extension file
- Write tests for all observer error conversion paths

**Done when**:
- ErrorConverter handles all ObserverError cases
- All error responses include required context fields
- Tests verify error conversion for each case

## S010: Observer Integration Tests

**Intent**: Verify end-to-end observer behavior with mocked dependencies.

**Work**:
- Write integration tests combining ObserverManager, EventCollector, and ObserveChangesHandler with MockAXBridge
- Test full flow: start observation → simulate events via mock → collect events → verify response
- Test duration enforcement end-to-end
- Test max event count enforcement end-to-end
- Test application termination during observation
- Test multiple simultaneous observations (different apps)
- Test observer cleanup (no leaked subscriptions after handler returns)
- Verify response JSON structure matches expected schema
- Verify ISO 8601 timestamps in events

**Done when**:
- Integration tests cover full observation lifecycle
- Concurrent observation tested
- Cleanup verified (no resource leaks)
- All tests pass with MockAXBridge

## S011: Update README with Observer Documentation

**Intent**: Document the observe_changes tool for users.

**Work**:
- Add observe_changes section to README:
  - Purpose: watch for UI changes in an application
  - Parameters: app (required), events (optional — list supported types), element_path (optional), duration (optional, note default and max)
  - Return value structure: events array with timestamps and element details, metadata about truncation and duration
  - Example usage showing observation of a text editor
  - Example showing what events look like in the response
- Add to the tool summary table
- Document limitations: batch model (not real-time streaming), max duration, max events per observation
- Add example showing the full loop: find element → observe changes → react

**Done when**:
- README documents observe_changes with parameters, return value, and examples
- Limitations clearly documented
- Tool summary table updated

## S012: Refactor ObserverContext for Sandi Metz Compliance

**Intent**: Bring ObserverContext.swift and all observer callback code into compliance with Sandi Metz 100-line type limit and 5-line method limit.

**Work**:
- Create new file `Sources/AccessibilityMCP/Observers/ObserverCallback.swift`
- Move `CallbackBox`, `observerCallback`, and `extractAttribute` from ObserverContext.swift to ObserverCallback.swift
- Extract ObserverContext.init() logic into helper methods:
  - Create `createAppElement(pid: pid_t, element: UIElement?) -> AXUIElement` private method
  - Create `createContextComponents(handler: @escaping @Sendable (ObserverEvent) -> Void) -> (CallbackBox, RunLoopThread)` private method
  - Reduce init body to 4-5 lines: assign notifications/handler, call helpers, call setupAndStart
- Refactor observerCallback() function:
  - Create `extractCallbackBox(from userData: UnsafeMutableRawPointer?) -> CallbackBox?` helper
  - Create `createEvent(from element: AXUIElement, notification: String) -> ObserverEvent?` helper
  - Reduce observerCallback body to 3-5 lines: extract box, create event (guard), yield
- Verify all methods ≤ 5 lines in body (excluding signature/braces)
- Verify ObserverContext.swift ≤ 100 lines of code (excluding blanks/comments)
- Verify ObserverCallback.swift ≤ 100 lines of code (excluding blanks/comments)
- Run full test suite to ensure all 227 tests still pass
- Verify Swift 6 strict concurrency build succeeds with zero warnings

**Done when**:
- ObserverContext.swift has ≤ 100 lines of code (excluding blanks/comments)
- ObserverCallback.swift exists and has ≤ 100 lines of code (excluding blanks/comments)
- All methods in both files have ≤ 5 lines in body (excluding signature/braces)
- All 227 tests pass
- Build succeeds with zero warnings
- No functional changes (pure refactoring)
