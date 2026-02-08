# Phase 0006: Observation

## Intent

Add the `observe_changes` MCP tool using AXObserver, enabling an LLM to subscribe to UI change notifications for a specified duration and receive a batch of collected events when the observation period ends. After this phase, the server supports the full read-observe-act loop: inspect UI state, watch for changes, then react.

This is the most architecturally complex phase because it introduces long-lived subscriptions that outlast a single synchronous tool call, callback-based C APIs (AXObserver) that must bridge to Swift structured concurrency, and RunLoop requirements that must coexist with the server's async runtime.

## Scope

### In scope

1. **MCP tool schema for `observe_changes`**:
   - `app` (required) — Application name or PID
   - `events` (optional) — Event types to watch: value_changed, focus_changed, window_created, window_destroyed, title_changed
   - `element_path` (optional) — Observe a specific element only
   - `duration` (optional, default: 30s, max: 300s) — How long to observe

2. **ObserverManager actor** in `Observers/` directory:
   - Create and manage AXObserver instances per subscription
   - Map C callbacks to Swift async events using AsyncStream
   - Handle subscription lifecycle: create, collect events, cleanup
   - Enforce duration limits (default 30s, max 300s)
   - Clean up observers on cancellation or server shutdown
   - Track active subscriptions to prevent resource leaks

3. **AXObserver RunLoop integration**:
   - AXObserverAddNotification requires a CFRunLoop source
   - Manage a dedicated thread or dispatch queue for the RunLoop
   - Bridge RunLoop-based callbacks into Swift structured concurrency

4. **Event collection and response model**:
   - Collect events during the observation period
   - Return collected events as structured JSON when duration expires
   - Each event includes: timestamp (ISO 8601), event type, affected element role/title/path, new value (if applicable)
   - Enforce maximum event count per observation (prevent unbounded memory usage)

5. **AXBridge protocol extension**:
   - Add observer-related methods to AXBridge protocol for testability
   - LiveAXBridge implements real AXObserver creation and notification registration
   - MockAXBridge provides test doubles

6. **ObserveChangesHandler** following the established handler pattern:
   - Parameters struct with validation
   - Response struct with collected events
   - Safety checks: read-only mode does NOT block (observation is read-only), blocklist does NOT apply (observation is read-only), but duration limits are enforced

7. **Wire to MCP server**:
   - Register `observe_changes` in tool list (always visible, not gated by read-only mode)
   - Add dispatch in callTool

8. **Tests**:
   - ObserverManager: creation, cleanup, duration enforcement, event collection
   - Event serialization to JSON
   - Multiple simultaneous observers
   - Observer cleanup (no leaks)
   - ObserveChangesHandler: parameter validation, success path, error paths
   - MockAXBridge observer support

9. **README update**: Document observe_changes tool with parameters and examples

### Out of scope

- Real-time streaming (events are batched and returned at end of duration)
- Modifying existing read or write tools
- MCP resource subscriptions or SSE-based notification push
- Persistent observers that survive across tool calls (each call is self-contained)
- Configuration file for observer settings (duration limits are hardcoded)

## Constraints

### Laws
- **L04**: Explicit application scope required — `app` parameter required
- **L06**: Element reference validation — `element_path` validated when provided
- **L12**: Structured JSON responses only — events returned as structured JSON
- **L13/L18**: Result set limits — maximum event count enforced per observation
- **L14**: ISO 8601 datetime format — event timestamps use ISO 8601
- **L17**: Operation timeout enforcement — duration limit enforced (max 300s)
- **L19**: No main thread blocking — observer runs on background thread/queue
- **L20**: Actor-based state management — ObserverManager uses actor isolation
- **L21**: Typed throws for all error-throwing functions
- **L22**: Swift Testing framework for all tests
- **L23**: Every public method tested
- **L27**: Unit tests use mocks, not real AX API
- **L36**: Minimal result logging — event data not logged
- **L37**: Error context preservation — errors include operation, element, and guidance
- **L39**: Graceful application termination handling — detect if observed app quits

### Style
- Sandi Metz rules: <=100 lines per type, <=5 lines per method, <=4 parameters
- Handler pattern from Phase 4/5: Parameters + Handler + Response
- Dependency injection for all collaborators
- Actor isolation for ObserverManager
- One type per file, files grouped by domain (Observers/, Tools/)
- Protocol-oriented: AXBridge extended for observer operations

## Acceptance Criteria

- `observe_changes` appears in MCP tool list (visible in both normal and read-only modes since observation is read-only)
- `observe_changes` with required `app` parameter starts observation, waits for specified duration, returns collected events
- Events include: timestamp (ISO 8601), event_type, element_role, element_title, element_path (if determinable), new_value (if applicable)
- Default duration is 30 seconds; maximum is 300 seconds; values beyond max are clamped
- Maximum event count per observation is enforced (events beyond limit are dropped with truncation notice)
- Observer is cleaned up after duration expires (no leaked AXObserver instances)
- If observed application terminates during observation, events collected so far are returned with a note about early termination
- AXBridge protocol extended with observer methods; MockAXBridge supports them
- All tests pass using MockAXBridge (no real AX API dependency)
- Swift build succeeds with zero warnings under Swift 6 strict concurrency
- README updated with observe_changes documentation and examples

## Risks / Notes

- **RunLoop requirement**: AXObserver needs a CFRunLoop source added via `CFRunLoopAddSource`. This conflicts with Swift's async/await model. The implementation must spin up a dedicated RunLoop (likely on a background thread via DispatchQueue) and bridge callbacks into an AsyncStream continuation. This is the key architectural challenge.
- **C callback to Swift bridging**: The AXObserverCallback is a C function pointer. Bridging context (the AsyncStream continuation) must be passed via the `refcon` (userData) pointer. Careful memory management is required to prevent dangling pointers or leaks.
- **Observation is read-only**: Unlike perform_action and set_value, observe_changes does not modify UI state. It should NOT be gated by read-only mode or blocklist. It is a passive listener.
- **Duration vs. server responsiveness**: During observation, the tool call blocks for the specified duration. This is inherent to the batch model. The MCP client must be prepared for long-running tool calls (up to 300s). Future phases could add streaming support.
- **Event flood**: A rapidly changing UI (e.g., a progress bar) can generate thousands of events per second. The maximum event count limit prevents unbounded memory growth. The response should indicate if events were truncated.
- **Application termination during observation**: If the observed app quits, the observer callback may stop firing or the observer may become invalid. The implementation must detect this (e.g., via kAXUIElementDestroyedNotification or periodic PID checks) and return early with collected events.
- **Multiple simultaneous observers**: The ObserverManager must support multiple concurrent observations (different apps, different elements). Each observation is independent and self-contained.
