# Project Style Guide

## Purpose

This style guide defines the conventions, patterns, and architectural expectations for AxMCP development. These guidelines promote consistency, maintainability, and code quality across the codebase. All contributors must follow these conventions unless explicitly justified otherwise.

Reviewers should verify adherence to this style guide before approving changes. Style violations should be identified and corrected during review.

This style guide governs **how** the system is built. Laws in `.ushabti/laws.md` define **non-negotiable invariants**. If a conflict arises between style and laws, laws take precedence.

---

## Project Structure

### Directory Layout

```
axmcp/
├── Sources/
│   ├── AxMCP/                      # Main server implementation
│   │   ├── Server/                 # MCP server infrastructure
│   │   ├── Tools/                  # MCP tool implementations
│   │   ├── ElementReference/       # Element path and resolution
│   │   ├── TreeTraversal/          # UI tree walking and serialization
│   │   ├── Actions/                # Action execution (write operations)
│   │   ├── Observers/              # AXObserver subscriptions
│   │   ├── AXBridge/               # C API bridging and type wrappers
│   │   ├── Security/               # Permissions, blocklists, rate limiting
│   │   └── Models/                 # Data models and types
│   └── AxMCPCore/                  # Reusable core components
├── Tests/
│   ├── AxMCPTests/                 # Main test suite
│   │   ├── Mocks/                  # Mock AX API implementations
│   │   └── Fixtures/               # Test fixtures and mock data
│   └── IntegrationTests/           # Tests using real test applications
├── TestApps/                       # Simple test applications for integration tests
├── Package.swift
├── README.md
├── CHANGELOG.md
└── .ushabti/                       # Ushabti framework files
```

### Module Boundaries

- **AxMCP**: Main executable module, MCP server implementation, tool definitions, element access, tree traversal, action execution
- **AxMCPCore**: Reusable abstractions for AX API access, security, utilities (if needed for test isolation or future reuse)

The separation between read and write operations must be architecturally clear. Read tools (tree traversal, element search) go in `TreeTraversal/` and `ElementReference/`. Write tools (actions, value setting) go in `Actions/`. This enables read-only mode enforcement (enforced by L16).

### File Organization

- **One type per file** (exception: small, tightly-coupled private types < 20 lines)
- **File name matches primary type name**: `ElementPath.swift` contains `struct ElementPath`
- **Group related files by feature/domain**: All tree traversal types in `TreeTraversal/`, all AX C API wrappers in `AXBridge/`

### Ownership Expectations

- Each module has a clear responsibility boundary
- Cross-module dependencies must go through well-defined protocols
- No circular dependencies between modules
- The `AXBridge/` module owns all direct C API interactions — other modules access AX functionality through Swift protocol abstractions

---

## Language & Tooling Conventions

### Language Version

- **Swift 6** language mode with strict concurrency checking (enforced by L01)
- Leverage Swift 6 features: typed throws, strict concurrency checking, memory safety guarantees

### Build Tools

- **Swift Package Manager** for dependency management and build
- **Swift Testing** framework for all tests (enforced by L22)

### Dependency Management

- Prefer system frameworks over third-party dependencies
- All dependencies must be justified and documented in README (enforced by L31)
- Primary dependencies: `ApplicationServices` framework (for AX API), Swift MCP SDK
- Avoid transitive dependency bloat
- Single binary output with no runtime dependencies beyond macOS system frameworks (enforced by L28)

---

## Sandi Metz's Rules (Enforced)

These rules enforce small, focused, composable design. They are strict conventions for this project.

### 1. Classes/Structs: Maximum 100 Lines of Code

- Excludes blank lines and comments
- If a type exceeds 100 lines, extract responsibilities into new types
- Favor composition over large, monolithic types

### 2. Methods: Maximum 5 Lines of Code

- Excludes blank lines and comments
- Forces single responsibility and clear naming
- Compose small methods into larger behaviors
- **Rationale**: Enforces clarity and testability. Methods that are too long are doing too much.

### 3. Methods: Maximum 4 Parameters

- If you need more than 4 parameters, create a parameter object (struct)
- Consider builder patterns for complex configuration
- **Example**: Prefer `func traverse(options: TraversalOptions)` over `func traverse(maxDepth: Int, filterRole: String?, includeHidden: Bool, timeout: TimeInterval)`

### 4. Top-Level Objects: Instantiate Only One Object

- Pass collaborators as dependencies via initializers
- Enforces loose coupling and testability
- **Example**: A server initializer should not create its own element resolver, permission checker, and rate limiter — these should be injected

### 5. Reminder: 100-Line Limit (Reinforced)

- This is a hard boundary. If you hit 100 lines, refactor immediately.

---

## Swift Idioms

### Prefer Immutability

- **Use `let` over `var` by default**
- Prefer value types (`struct`, `enum`) over reference types (`class`) when appropriate
- Immutable collections unless mutation is required: `let elements: [UIElement]` over `var elements: [UIElement]`

### Functional Patterns

- **Prefer `map`, `filter`, `reduce`, `compactMap` over imperative loops**
  ```swift
  // Good
  let validElements = elements.compactMap { $0.validate() }

  // Avoid
  var validElements: [UIElement] = []
  for element in elements {
      if let validated = element.validate() {
          validElements.append(validated)
      }
  }
  ```
- Use higher-order functions for collection transformations
- **Avoid side effects in pure functions** — mark side-effecting functions clearly:
  ```swift
  // Pure function
  func resolveElementPath(_ path: ElementPath) -> UIElement? { ... }

  // Side-effecting function (document clearly)
  func performAction(_ action: AXAction, on element: UIElement) throws { ... }  // Mutates UI state
  ```

### Error Handling

- **Use typed `throws` (Swift 6)** (enforced by L21)
  ```swift
  func traverse(element: UIElement, maxDepth: Int) throws(TreeTraversalError) -> TreeNode
  ```
- **Never use `try!` or force-unwrapping in production code**
- Provide descriptive error types that aid debugging:
  ```swift
  enum ElementReferenceError: Error {
      case invalidPath(String)
      case elementNotFound(ElementPath)
      case staleReference(ElementPath)
      case permissionDenied(applicationName: String)
  }
  ```
- Errors must include context for diagnosis (enforced by L37)

### Optionals

- Use optional chaining and nil coalescing operators
- **Avoid force-unwrapping** — prefer `guard` statements or `if let`:
  ```swift
  // Good
  guard let element = resolveElement(path) else { return }

  // Avoid
  let element = resolveElement(path)!
  ```
- Make optionality explicit in types: `var cachedTree: TreeNode?` clearly indicates optional state

### Naming

- **Clarity over brevity**
- Methods should read like sentences:
  ```swift
  element.getAttribute(.title)
  path.resolve(in: application)
  action.perform(on: element, withTimeout: 2.0)
  ```
- **Avoid abbreviations** unless universally understood (`UI`, `AX`, `ID`, `JSON`, `URL` are acceptable)
- **Boolean properties should read as assertions**:
  ```swift
  isValid
  hasChildren
  canPerformAction
  shouldLimitDepth
  isStale
  ```

---

## Code Organization

### Type Organization (Within a File)

Organize type definitions in this order:

1. **Type declaration and stored properties**
2. **Initialization**
3. **Public interface** (public methods)
4. **Internal/private implementation** (private methods)
5. **Extensions for protocol conformance** (each protocol in its own extension)

**Example:**
```swift
struct ElementPath {
    // 1. Properties
    let components: [PathComponent]
    let applicationPID: pid_t

    // 2. Initialization
    init(components: [PathComponent], applicationPID: pid_t) {
        self.components = components
        self.applicationPID = applicationPID
    }

    // 3. Public interface
    func resolve(using resolver: ElementResolver) throws(ElementReferenceError) -> UIElement {
        validate()
        return try performResolution(using: resolver)
    }

    // 4. Private implementation
    private func validate() throws(ElementReferenceError) { ... }
    private func performResolution(using resolver: ElementResolver) throws -> UIElement { ... }
}

// 5. Protocol conformance
extension ElementPath: Equatable {}
extension ElementPath: Codable {}
```

### Dependency Management

- **Dependencies injected via initializers**
- **No singletons** except for true application-wide state (logging, configuration)
- **Protocols for abstraction boundaries**:
  ```swift
  protocol ElementResolver {
      func resolve(_ path: ElementPath) throws(ElementReferenceError) -> UIElement
  }

  struct DefaultElementResolver: ElementResolver { ... }
  ```
- **Prefer composition over inheritance**

---

## Architectural Patterns

### Patterns to Embrace

#### Protocol-Oriented Programming

Define behavior through protocols. Use protocols to create abstraction boundaries and enable testability. This is especially critical for the C API bridge layer.

```swift
protocol AXElementAccessor {
    func getAttribute<T>(_ attribute: AXAttribute, from element: AXUIElement) throws(AXError) -> T
    func performAction(_ action: AXAction, on element: AXUIElement) throws(AXError)
}

struct SystemAXElementAccessor: AXElementAccessor { ... }
struct MockAXElementAccessor: AXElementAccessor { ... }  // For tests
```

#### Value Semantics

Prefer structs and enums for data models. Value types provide safety, immutability by default, and eliminate reference-sharing bugs.

```swift
struct UIElement {
    let role: String
    let title: String?
    let value: AXValue?
    let bounds: CGRect
    let children: [UIElement]
}

struct TreeNode {
    let element: UIElement
    let depth: Int
    let children: [TreeNode]
}
```

#### Result Builders

For DSL-like APIs where appropriate (e.g., element query construction, tree filtering):

```swift
@resultBuilder
struct ElementQueryBuilder {
    static func buildBlock(_ components: QueryPredicate...) -> ElementQuery {
        ElementQuery(predicates: components)
    }
}
```

#### Actor Isolation

For thread-safe state management (enforced by L20). Use actors to protect mutable shared state.

```swift
actor RateLimiter {
    private var actionTimestamps: [Date] = []
    private let maxActionsPerSecond: Int

    func checkLimit() async throws(RateLimitError) {
        // Enforce rate limit
    }

    func recordAction() {
        actionTimestamps.append(Date())
    }
}

actor ObserverManager {
    private var activeObservers: [pid_t: AXObserver] = [:]

    func register(observer: AXObserver, for pid: pid_t) {
        activeObservers[pid] = observer
    }

    func unregister(for pid: pid_t) {
        activeObservers.removeValue(forKey: pid)
    }
}
```

### Patterns to Avoid

- **Massive server objects**: Break up into smaller, focused types
- **Direct C API usage throughout codebase**: Isolate C API interactions in `AXBridge/` module
- **Inheritance hierarchies**: Prefer protocol composition and value types
- **Mutable shared state without actors**: Use actors or eliminate mutability (enforced by L20)
- **Stringly-typed APIs**: Use enums and strong types instead of string constants
- **Unbounded tree traversal**: Always enforce depth limits (enforced by L05)

---

## Domain-Specific Architectural Patterns

### Element Referencing Strategy

AXUIElement references are ephemeral and cannot be serialized or stored across MCP calls. The server must use **path-based element references** that can be reconstructed on each invocation.

#### Element Path Structure

Element paths are hierarchical identifiers that describe the route from an application to a specific element:

```swift
struct ElementPath {
    let applicationPID: pid_t
    let components: [PathComponent]
}

enum PathComponent {
    case window(index: Int)
    case windowByTitle(String)
    case child(index: Int)
    case childWithRole(role: String, index: Int)
    case childWithTitle(role: String, title: String)
}
```

**Example paths:**
- `app(12345)/window[0]/toolbar/button[Save]`
- `app(12345)/window["Document1"]/splitGroup[0]/textArea`

#### Element Path Resolution

Resolution walks the path from application root to target element:

```swift
protocol ElementResolver {
    func resolve(_ path: ElementPath) throws(ElementReferenceError) -> UIElement
}
```

**Validation requirements (enforced by L06):**
- Every element path received from clients must be validated before resolution
- Invalid or stale references must return structured errors, never crash
- Resolution must enforce timeouts (enforced by L17)

### Read vs. Write Operation Separation

Clear architectural boundaries between read and write operations are essential (enforced by L16).

#### Read Operations (No Side Effects)

- Tree traversal: `getUITree(application:maxDepth:)`
- Element search: `findElement(query:in:)`
- Attribute access: `getElementAttributes(element:)`
- Window listing: `listWindows(application:)`
- Focused element: `getFocusedElement()`

**Characteristics:**
- No mutation of application UI state
- Can be called at any rate
- Safe for read-only mode

#### Write Operations (Mutate UI State)

- Action execution: `performAction(action:on:)`
- Value setting: `setValue(_:on:attribute:)`

**Characteristics:**
- Mutate application UI state (enforced by L16)
- Subject to rate limiting (enforced by L10)
- Blocked in read-only mode (enforced by L08)
- Documented as destructive where applicable (enforced by L08)
- Must return post-action state for verification (enforced by L11)

**Read-only mode enforcement:**
```swift
struct ServerConfiguration {
    let readOnlyMode: Bool
    // ...
}

// Write operations check mode before execution
func performAction(_ action: AXAction, on element: UIElement) throws(ActionError) {
    guard !configuration.readOnlyMode else {
        throw ActionError.readOnlyModeEnabled
    }
    // Execute action
}
```

### C API Bridging Patterns

The Accessibility API is C-level. All C type interactions must be isolated in the `AXBridge/` module. Other modules interact with Swift protocol abstractions.

#### C Type Wrapping

```swift
// AXBridge/AXElementWrapper.swift
struct AXElementWrapper {
    private let rawElement: AXUIElement

    init(rawElement: AXUIElement) {
        self.rawElement = rawElement
    }

    func getAttribute<T>(_ attribute: String) throws(AXError) -> T {
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(rawElement, attribute as CFString, &value)
        guard error == .success else {
            throw AXError.fromCode(error)
        }
        guard let typedValue = value as? T else {
            throw AXError.typeMismatch(expected: T.self, actual: type(of: value))
        }
        return typedValue
    }
}
```

#### Type Safety (Enforced by L38)

All attribute retrievals must:
- Type-check CFTypeRef returns
- Safely coerce to expected Swift types
- Return structured errors on type mismatches, never crash

```swift
// Good: Type-safe attribute access
func getTitle(from element: AXUIElement) throws(AXError) -> String? {
    do {
        let title: String = try wrapper.getAttribute(kAXTitleAttribute)
        return title
    } catch AXError.attributeNotFound {
        return nil  // Attribute doesn't exist (valid case)
    }
}

// Avoid: Unsafe casting
let title = try wrapper.getAttribute(kAXTitleAttribute) as! String  // Can crash
```

### Tree Traversal and Serialization

UI trees can be enormous (thousands of elements for complex applications). Tree traversal must be depth-limited, filterable, and efficiently serializable.

#### Depth Limiting (Enforced by L05)

```swift
struct TreeTraversalOptions {
    let maxDepth: Int  // Required, no unbounded default
    let filterRoles: Set<String>?
    let includeHidden: Bool
    let timeout: TimeInterval
}

func traverse(element: UIElement, options: TreeTraversalOptions) throws(TreeTraversalError) -> TreeNode {
    guard options.maxDepth > 0 else {
        throw TreeTraversalError.maxDepthExceeded
    }
    // Traverse with depth limit
}
```

**Default depth limit:** 10 levels (documented, conservative)

#### Lazy Tree Expansion

For large trees, support lazy expansion where only the first N children at each level are returned, with a continuation token for fetching more:

```swift
struct TreeNode {
    let element: UIElement
    let depth: Int
    let children: [TreeNode]
    let hasMoreChildren: Bool
    let continuationToken: String?
}
```

#### Tree Serialization to JSON

All tree nodes must serialize to consistent JSON structure:

```swift
{
    "role": "AXButton",
    "title": "Save",
    "value": null,
    "bounds": {"x": 100, "y": 200, "width": 80, "height": 24},
    "depth": 3,
    "children": [...],
    "hasMoreChildren": false
}
```

### Observer Lifecycle Management

AXObserver subscriptions require careful lifecycle management with structured concurrency.

#### Observer Creation and Registration

```swift
actor ObserverManager {
    private var observers: [pid_t: ObserverState] = [:]

    struct ObserverState {
        let observer: AXObserver
        let subscriptions: Set<AXNotification>
        let continuation: AsyncStream<AXNotification>.Continuation
    }

    func createObserver(for application: pid_t, notifications: [AXNotification]) async throws -> AsyncStream<AXNotification> {
        // Create observer, register notifications, return stream
    }

    func removeObserver(for application: pid_t) async {
        // Clean up observer and subscriptions
    }
}
```

#### Callback to Structured Concurrency Bridge

AXObserver uses C callbacks. Bridge these to Swift async streams:

```swift
// C callback handler
func axObserverCallback(
    observer: AXObserver,
    element: AXUIElement,
    notification: CFString,
    userData: UnsafeMutableRawPointer?
) {
    // Marshal to continuation
    let continuation = userData.assumingMemoryBound(to: AsyncStream<AXNotification>.Continuation.self).pointee
    continuation.yield(AXNotification(element: element, name: notification as String))
}
```

#### Subscription Cleanup

Observers must be properly cleaned up when:
- Client unsubscribes explicitly
- Target application terminates (enforced by L39)
- Server shuts down

---

## Security Patterns

### Permission Detection (Enforced by L07)

Check Accessibility permissions at startup and on first AX API access:

```swift
func checkAccessibilityPermissions() throws(PermissionError) {
    let trusted = AXIsProcessTrusted()
    guard trusted else {
        throw PermissionError.accessibilityNotGranted(
            guidance: "Grant Accessibility permissions in System Settings > Privacy & Security > Accessibility"
        )
    }
}
```

### Application Blocklist (Enforced by L09)

```swift
struct ApplicationBlocklist {
    private let blockedBundleIDs: Set<String>

    static let defaultBlocklist: Set<String> = [
        "com.apple.keychainaccess",
        "com.apple.systempreferences",  // System Settings
        "com.1password.1password",
        // ...
    ]

    func isBlocked(_ bundleID: String) -> Bool {
        blockedBundleIDs.contains(bundleID)
    }
}
```

### Element Reference Validation (Enforced by L06)

All element paths must be validated before resolution:

```swift
func validateElementPath(_ path: ElementPath) throws(ElementReferenceError) {
    // Check path component count
    guard path.components.count <= maxPathLength else {
        throw ElementReferenceError.pathTooLong(path.components.count)
    }

    // Validate application PID
    guard path.applicationPID > 0 else {
        throw ElementReferenceError.invalidPID(path.applicationPID)
    }

    // Additional validation...
}
```

---

## Testing Strategy

### What Must Be Tested

- **Every public method** (enforced by L23)
- **Error paths and edge cases**
- **Security-sensitive code** (permission checking, blocklist enforcement, element validation, rate limiting)
- **Integration points** (MCP protocol, AX API interactions)
- **Tree traversal depth limiting** (verify enforcement)
- **Timeout enforcement** (verify operations respect timeouts)
- **Type safety** (verify attribute coercion handles type mismatches)

### Test Location

- Unit tests live in `Tests/AxMCPTests/`
- Integration tests live in `Tests/IntegrationTests/`
- Test files mirror source structure: `Sources/AxMCP/TreeTraversal/TreeNode.swift` → `Tests/AxMCPTests/TreeTraversal/TreeNodeTests.swift`
- Mocks and fixtures in `Tests/AxMCPTests/Mocks/` and `Tests/Fixtures/`

### Test Principles

- **Idempotent and order-independent** (enforced by L25)
- **Use mocks for AX API, never real user apps** (enforced by L27 for unit tests, L26 for integration tests)
- **Simple test applications for integration tests** (use controlled test apps in `TestApps/`, not user applications)
- **Descriptive test names**: `testTreeTraversalRespectsMaxDepth()`, not `testTraversal1()`

### Acceptable Testing Tradeoffs

- **Unit tests over integration tests** where practical (faster, more isolated)
- **Mock AX API for unit tests** (enforced by L27) — use protocol-based stubs:
  ```swift
  struct MockAXElementAccessor: AXElementAccessor {
      var mockAttributes: [String: Any] = [:]
      var mockActions: Set<String> = []

      func getAttribute<T>(_ attribute: AXAttribute, from element: AXUIElement) throws(AXError) -> T {
          guard let value = mockAttributes[attribute] as? T else {
              throw AXError.attributeNotFound
          }
          return value
      }
  }
  ```
- **Integration tests use controlled test applications** (enforced by L26) — simple apps in `TestApps/` with known UI structures

### Test Organization

```swift
import Testing
@testable import AxMCP

@Suite("ElementPath Tests")
struct ElementPathTests {

    @Test("Element path resolution respects depth limit")
    func resolutionRespectsDepthLimit() throws {
        let path = ElementPath(
            applicationPID: 12345,
            components: [.window(index: 0), .child(index: 0), .child(index: 1)]
        )
        let resolver = MockElementResolver()
        let element = try path.resolve(using: resolver)
        #expect(element.depth == 3)
    }

    @Test("Invalid element path throws structured error")
    func invalidPathThrowsError() {
        let path = ElementPath(applicationPID: -1, components: [])
        let resolver = MockElementResolver()
        #expect(throws: ElementReferenceError.invalidPID) {
            try path.resolve(using: resolver)
        }
    }
}

@Suite("Tree Traversal Tests")
struct TreeTraversalTests {

    @Test("Tree traversal enforces max depth")
    func traversalEnforcesMaxDepth() throws {
        let options = TreeTraversalOptions(maxDepth: 3, filterRoles: nil, includeHidden: false, timeout: 2.0)
        let mockElement = createMockElementTree(depth: 10)  // Deeper than max
        let tree = try traverse(element: mockElement, options: options)
        #expect(tree.maxDepth() <= 3)
    }

    @Test("Tree traversal respects timeout")
    func traversalRespectsTimeout() {
        let options = TreeTraversalOptions(maxDepth: 100, filterRoles: nil, includeHidden: false, timeout: 0.1)
        let slowElement = createSlowMockElement()
        #expect(throws: TreeTraversalError.timeoutExceeded) {
            try traverse(element: slowElement, options: options)
        }
    }
}
```

---

## Error Handling & Observability

### Logging

- Use structured logging (e.g., `Logger` from `os.log`)
- **Minimal UI data logging** (enforced by L36) — do not log element attributes, values, or content in production
- Log levels:
  - **Error**: Failures requiring attention (permission denied, application not found, timeout exceeded)
  - **Warning**: Recoverable issues (stale element reference, action failed but safe to retry)
  - **Info**: High-level operational events (server start, tool invocation, observer registration)
  - **Debug**: Detailed diagnostic information (element path resolution steps, tree traversal progress — disabled in release builds)

### Error Propagation

- Throw errors upward with typed throws (enforced by L21)
- Handle errors at appropriate boundaries (MCP tool layer converts errors to JSON responses)
- Provide context in error messages (enforced by L37):
  ```swift
  // Good: includes context
  throw ElementReferenceError.elementNotFound(path, reason: "Window index out of range")

  // Bad: no context
  throw ElementReferenceError.elementNotFound()
  ```

### Error Context Requirements (Enforced by L37)

All errors returned to MCP clients must include:
- Operation attempted ("resolve_element_path", "perform_action")
- Element reference or path if applicable
- Underlying AX API error code if available
- Actionable guidance when possible ("Check that the application is running", "Verify Accessibility permissions")

```swift
struct StructuredError: Codable {
    let operation: String
    let errorType: String
    let message: String
    let elementPath: String?
    let axErrorCode: Int?
    let guidance: String?
}
```

### Metrics / Tracing

- If performance monitoring is needed in the future, instrument at tool boundaries
- Measure operation latency, tree traversal depth and element counts, timeout occurrences, rate limit hits
- Not required for initial implementation

---

## Performance & Resource Use

### Expectations

- Tree traversal operations should complete within documented timeout (enforced by L17)
- Result sets capped at documented limits (enforced by L13, L18)
- Memory usage proportional to tree depth and result set size (no unbounded allocations)
- Action operations complete within reasonable time (< 5 seconds for typical actions)

### Common Pitfalls

- **Unbounded tree traversal**: Always enforce depth limits (enforced by L05)
- **Main thread blocking**: Use background queues for AX API operations (enforced by L19)
- **Excessive logging**: Avoid logging element attributes or large result sets (enforced by L36)
- **Retaining large trees**: Return tree snapshots and release references promptly
- **Not handling slow/unresponsive applications**: Enforce timeouts on all AX operations (enforced by L17)
- **Observer memory leaks**: Clean up AXObserver subscriptions when no longer needed

---

## Review Checklist

Before approving any change, reviewers must verify:

### Code Quality

- [ ] All types ≤ 100 lines (Sandi Metz rule)
- [ ] All methods ≤ 5 lines (Sandi Metz rule)
- [ ] All methods ≤ 4 parameters (Sandi Metz rule)
- [ ] Dependencies injected, not instantiated (Sandi Metz rule)
- [ ] No dead code (enforced by L24)
- [ ] `let` preferred over `var` where possible
- [ ] No force-unwrapping (`!`) in production code

### Error Handling

- [ ] Typed throws used for all error-throwing functions (enforced by L21)
- [ ] Descriptive error types with context (enforced by L37)
- [ ] No `try!` in production code

### Security & Safety

- [ ] Element references validated before use (enforced by L06)
- [ ] Application scope explicit and validated (enforced by L04)
- [ ] Accessibility permissions checked and handled (enforced by L07)
- [ ] Application blocklist enforced (enforced by L09)
- [ ] Destructive actions documented (enforced by L08)
- [ ] Read-only mode supported and tested (enforced by L08)
- [ ] Rate limiting implemented for write operations (enforced by L10)
- [ ] No sensitive UI data logged (enforced by L36)

### Testing

- [ ] Every public method has at least one test (enforced by L23)
- [ ] Tests are idempotent and order-independent (enforced by L25)
- [ ] Tests use mocks for AX API in unit tests (enforced by L27)
- [ ] Tests use controlled test apps, not user data (enforced by L26)
- [ ] Tests verify depth limit enforcement (enforced by L05)
- [ ] Tests verify timeout enforcement (enforced by L17)
- [ ] Tests verify type safety on attribute access (enforced by L38)

### Documentation

- [ ] Public APIs documented with clear descriptions
- [ ] README updated if tools or configuration changed (enforced by L31)
- [ ] `.ushabti/docs` reconciled with code changes (enforced by L33, L34, L35)
- [ ] CHANGELOG updated for releases (enforced by L30)

### Protocol Compliance

- [ ] MCP tools return structured JSON (enforced by L12)
- [ ] Result set limits documented and enforced (enforced by L13, L18)
- [ ] Timeouts enforced on AX operations (enforced by L17)
- [ ] Absolute file paths in responses if applicable (enforced by L15)
- [ ] ISO 8601 for datetime values (enforced by L14)
- [ ] Read vs. write operation separation clear (enforced by L16)
- [ ] Post-action state verification support (enforced by L11)

### Concurrency

- [ ] No blocking operations on main thread (enforced by L19)
- [ ] Actors used for shared mutable state (enforced by L20)

### AX API Interactions

- [ ] C API interactions isolated to `AXBridge/` module
- [ ] Type checking on all attribute retrievals (enforced by L38)
- [ ] Graceful handling of application termination (enforced by L39)
- [ ] No use of private or undocumented APIs (enforced by L02)
- [ ] No privilege escalation (enforced by L03)

### Phase Scope Compliance

- [ ] Phase 1: No write operations (read-only tree traversal, search, inspection) (enforced by L40)
- [ ] Phase 2: Write operations added after Phase 1 complete (enforced by L40)
- [ ] Phase 3: Observer support added after Phase 2 complete (enforced by L40)

---

## Writing Rules

When writing code or reviewing changes, follow these principles:

1. **Be explicit and actionable**: Prefer concrete guidance over abstract principles
2. **Prefer examples over abstractions**: Show what good code looks like
3. **Avoid "should" unless flexibility is intentional**: Use "must" for requirements
4. **Avoid vague guidance**: Replace "clean," "simple," "nice" with specific expectations
5. **Keep code concise but complete**: Favor small, focused types and methods

---

## Summary

This style guide establishes conventions for building AxMCP with clarity, consistency, and maintainability. By following Sandi Metz's rules, Swift idioms, domain-specific patterns for element referencing and tree traversal, and the patterns outlined here, we ensure a codebase that is easy to understand, test, and evolve.

All style guidance is compatible with the laws defined in `.ushabti/laws.md`. If a conflict arises, laws take precedence.

The architectural separation between read and write operations, the isolation of C API interactions, and the emphasis on safety and validation reflect the unique requirements of this domain: providing LLM-driven automation of arbitrary application UIs through a powerful but potentially destructive API.
