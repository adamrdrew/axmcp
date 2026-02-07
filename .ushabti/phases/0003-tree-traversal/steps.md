# Implementation Steps

## S001: Define TreeNode Value Type

**Intent**: Create the serializable tree representation that gets returned to MCP clients.

**Work**:
- Create `Sources/AccessibilityMCP/TreeTraversal/TreeNode.swift`
- Define `struct TreeNode: Codable, Equatable`
- Fields: `role: String`, `title: String?`, `value: String?`, `children: [TreeNode]`, `actions: [String]`, `path: String`, `childCount: Int`, `depth: Int`
- Implement Codable conformance for JSON serialization
- Ensure all fields serialize to clean JSON (no optionals encoded as null if possible)

**Done when**:
- TreeNode.swift exists with all required fields
- TreeNode conforms to Codable and Equatable
- File is ≤100 lines
- No force-unwrapping

---

## S002: Define TreeTraversalOptions Configuration Struct

**Intent**: Encapsulate all configuration for tree traversal in a single type (Sandi Metz rule: ≤4 parameters).

**Work**:
- Create `Sources/AccessibilityMCP/TreeTraversal/TreeTraversalOptions.swift`
- Define `struct TreeTraversalOptions`
- Fields: `maxDepth: Int` (required), `filterRoles: Set<ElementRole>?` (optional), `includeAttributes: Set<ElementAttribute>?` (optional), `timeout: TimeInterval` (default 5.0)
- Add documentation comments for each field
- Provide a convenience initializer with sensible defaults

**Done when**:
- TreeTraversalOptions.swift exists with all fields
- Default timeout is 5.0 seconds
- File is ≤100 lines
- No force-unwrapping

---

## S003: Define TreeTraversalError Type

**Intent**: Typed errors for tree traversal failures.

**Work**:
- Create `Sources/AccessibilityMCP/TreeTraversal/TreeTraversalError.swift`
- Define `enum TreeTraversalError: Error` with cases:
  - `invalidDepth(Int)` — maxDepth < 1
  - `timeoutExceeded(TimeInterval)` — traversal exceeded timeout
  - `accessibilityError(AccessibilityError)` — underlying AX API error
  - `invalidElement` — element reference is invalid
- Include associated values for context

**Done when**:
- TreeTraversalError.swift exists with all error cases
- Error type includes sufficient context for diagnosis
- File is ≤100 lines

---

## S004: Implement TreeTraverser

**Intent**: Core tree walking logic with depth limiting, filtering, and timeout enforcement.

**Work**:
- Create `Sources/AccessibilityMCP/TreeTraversal/TreeTraverser.swift`
- Define `struct TreeTraverser`
- Implement `func traverse(element: UIElement, options: TreeTraversalOptions, bridge: any AXBridge) throws(TreeTraversalError) -> TreeNode`
- Walk tree recursively, respecting maxDepth
- Apply role filter if present (skip nodes not in filterRoles)
- Apply attribute filter if present (only populate requested attributes)
- Build ElementPath for each node (defer path string construction to ElementPath type)
- Enforce timeout using structured concurrency (Task.withTimeout or similar)
- Extract helper methods to keep all methods ≤5 lines
- Use extensions if needed to stay under 100-line limit

**Done when**:
- TreeTraverser.swift exists with traverse() method
- Depth limiting works (stops at maxDepth)
- Role filtering works (skips non-matching roles)
- Attribute filtering works (only includes requested attributes)
- Timeout enforcement works
- All methods ≤5 lines
- File (including extensions) respects 100-line limit per type
- No force-unwrapping

---

## S005: Define ElementPathComponent Enum

**Intent**: Represent individual path segments with type safety.

**Work**:
- Create `Sources/AccessibilityMCP/ElementReference/ElementPathComponent.swift`
- Define `enum ElementPathComponent: Equatable, Hashable`
- Cases:
  - `appByName(String)` — application by name
  - `appByPID(pid_t)` — application by process ID
  - `windowByIndex(Int)` — window by index
  - `windowByTitle(String)` — window by title
  - `childByRole(ElementRole, index: Int)` — child by role and index
  - `childByRoleAndTitle(ElementRole, title: String)` — child by role and title
- Implement string parsing and serialization methods

**Done when**:
- ElementPathComponent.swift exists with all cases
- Enum is Equatable and Hashable
- File is ≤100 lines
- No force-unwrapping

---

## S006: Define ElementPath Value Type

**Intent**: Path-based element references that are human-readable and round-trip through strings.

**Work**:
- Create `Sources/AccessibilityMCP/ElementReference/ElementPath.swift`
- Define `struct ElementPath: Equatable, Hashable, Codable`
- Fields: `components: [ElementPathComponent]`
- Implement `init(parsing: String) throws(ElementPathError)` — parse from string format
- Implement `func toString() -> String` — serialize to string format
- Ensure round-trip fidelity: `ElementPath(parsing: path.toString()) == path`
- Conform to Codable (serialize/deserialize as string)

**Done when**:
- ElementPath.swift exists with parsing and serialization
- Round-trip works: parse → serialize → parse yields same path
- ElementPath is Equatable, Hashable, and Codable
- File is ≤100 lines
- No force-unwrapping

---

## S007: Define ElementPathError Type

**Intent**: Typed errors for path parsing and resolution failures.

**Work**:
- Create `Sources/AccessibilityMCP/ElementReference/ElementPathError.swift`
- Define `enum ElementPathError: Error` with cases:
  - `invalidFormat(String)` — path string cannot be parsed
  - `emptyPath` — path has no components
  - `pathTooLong(Int)` — exceeds maximum length
  - `invalidPID(pid_t)` — PID is invalid (≤0)
  - `componentNotFound(ElementPathComponent, available: [String])` — component couldn't be matched, includes what was available
  - `elementNotFound(ElementPath)` — entire path couldn't be resolved
  - `staleReference(ElementPath)` — path was valid but element is gone
  - `timeoutExceeded(TimeInterval)` — resolution exceeded timeout
  - `accessibilityError(AccessibilityError)` — underlying AX API error
- Include associated values for context

**Done when**:
- ElementPathError.swift exists with all error cases
- Errors include sufficient context (expected vs. actual)
- File is ≤100 lines

---

## S008: Implement ElementResolver

**Intent**: Resolve ElementPath to live UIElement by walking the tree.

**Work**:
- Create `Sources/AccessibilityMCP/ElementReference/ElementResolver.swift`
- Define `struct ElementResolver`
- Implement `func resolve(path: ElementPath, bridge: any AXBridge) throws(ElementPathError) -> UIElement`
- Validate path before walking (check path length, validate PID)
- Walk each component, matching by role/index/title
- Return descriptive error if any component fails to match (include what was expected and what was found)
- Enforce timeout using structured concurrency
- Extract helper methods to keep all methods ≤5 lines
- Use extensions if needed to stay under 100-line limit

**Done when**:
- ElementResolver.swift exists with resolve() method
- Path validation works (rejects invalid PIDs, overly long paths)
- Path resolution walks each component correctly
- Errors include expected vs. actual context (e.g., "Expected window 'Document1', found ['Untitled', 'README']")
- Timeout enforcement works
- All methods ≤5 lines
- File respects 100-line limit per type
- No force-unwrapping

---

## S009: Define SearchCriteria Value Type

**Intent**: Encapsulate search parameters in a single configuration type.

**Work**:
- Create `Sources/AccessibilityMCP/ElementReference/SearchCriteria.swift`
- Define `struct SearchCriteria`
- Fields: `role: ElementRole?`, `titleSubstring: String?`, `value: String?`, `identifier: String?`, `caseSensitive: Bool` (default false), `maxResults: Int` (default 20)
- Provide convenience initializers for common search patterns

**Done when**:
- SearchCriteria.swift exists with all fields
- Default caseSensitive is false (case-insensitive by default)
- Default maxResults is 20
- File is ≤100 lines

---

## S010: Implement ElementFinder

**Intent**: Search for elements matching criteria within an application tree.

**Work**:
- Create `Sources/AccessibilityMCP/ElementReference/ElementFinder.swift`
- Define `struct ElementFinder`
- Implement `func find(criteria: SearchCriteria, in element: UIElement, bridge: any AXBridge) throws(TreeTraversalError) -> [(UIElement, ElementPath)]`
- Use TreeTraverser internally to walk the tree (no duplicate tree walking logic)
- Match elements against criteria (role, title substring, value, identifier)
- Case-insensitive title matching by default (respect caseSensitive flag)
- Enforce maxResults limit (stop searching once limit reached)
- Return array of (UIElement, ElementPath) tuples
- Extract helper methods to keep all methods ≤5 lines
- Use extensions if needed to stay under 100-line limit

**Done when**:
- ElementFinder.swift exists with find() method
- Uses TreeTraverser internally (no duplicate traversal logic)
- Matches by role, title, value, identifier correctly
- Case-insensitive title matching works by default
- maxResults limit is enforced
- Returns elements with their paths
- All methods ≤5 lines
- File respects 100-line limit per type
- No force-unwrapping

---

## S011: Test TreeNode JSON Serialization

**Intent**: Verify TreeNode serializes to clean, consistent JSON.

**Work**:
- Create `Tests/AccessibilityMCPTests/TreeTraversal/TreeNodeTests.swift`
- Test TreeNode encoding to JSON
- Test TreeNode decoding from JSON
- Test round-trip: encode → decode → encode yields same JSON
- Verify optional fields (title, value) are handled correctly
- Verify nested children serialize correctly

**Done when**:
- TreeNodeTests.swift exists with JSON serialization tests
- All tests pass
- Uses Swift Testing framework (@Test annotations)
- File is ≤100 lines

---

## S012: Test TreeTraverser Depth Limiting

**Intent**: Verify tree traversal enforces maxDepth correctly.

**Work**:
- Create `Tests/AccessibilityMCPTests/TreeTraversal/TreeTraverserTests.swift`
- Use MockAXBridge to create a deep mock tree (10+ levels)
- Test traversal with maxDepth=3 stops at depth 3
- Test traversal with maxDepth=1 returns only root node (no children)
- Test traversal with maxDepth=10 on a 5-level tree returns full tree
- Verify childCount field is accurate even when children are truncated

**Done when**:
- TreeTraverserTests.swift exists with depth limiting tests
- Tests use MockAXBridge (no real AX API)
- All tests pass
- Uses Swift Testing framework
- File is ≤100 lines

---

## S013: Test TreeTraverser Role Filtering

**Intent**: Verify tree traversal respects role filters.

**Work**:
- Add tests to `Tests/AccessibilityMCPTests/TreeTraversal/TreeTraverserTests.swift`
- Create mock tree with mixed roles (buttons, text fields, groups)
- Test traversal with filterRoles=[.button] returns only buttons
- Test traversal with filterRoles=[.button, .textField] returns both
- Test traversal with no filter returns all roles

**Done when**:
- Role filtering tests exist in TreeTraverserTests.swift
- Tests use MockAXBridge
- All tests pass
- File remains ≤100 lines (or extract to separate test file if needed)

---

## S014: Test TreeTraverser Attribute Filtering

**Intent**: Verify tree traversal respects attribute filters.

**Work**:
- Add tests to `Tests/AccessibilityMCPTests/TreeTraversal/TreeTraverserTests.swift` (or create new file if over 100 lines)
- Create mock elements with multiple attributes
- Test traversal with includeAttributes=[.role, .title] populates only those attributes
- Test traversal with no attribute filter includes all available attributes

**Done when**:
- Attribute filtering tests exist
- Tests use MockAXBridge
- All tests pass
- File respects 100-line limit (split into multiple test files if needed)

---

## S015: Test TreeTraverser Timeout Enforcement

**Intent**: Verify tree traversal enforces timeout.

**Work**:
- Add tests to `Tests/AccessibilityMCPTests/TreeTraversal/TreeTraverserTests.swift` (or create new file)
- Create mock that simulates slow AX operations (introduce delay)
- Test traversal with timeout=0.1 seconds throws TimeoutError
- Test traversal with sufficient timeout succeeds

**Done when**:
- Timeout enforcement tests exist
- Tests use MockAXBridge with simulated delays
- All tests pass
- File respects 100-line limit

---

## S016: Test ElementPath Parsing

**Intent**: Verify ElementPath parses from string format correctly.

**Work**:
- Create `Tests/AccessibilityMCPTests/ElementReference/ElementPathTests.swift`
- Test parsing simple paths: `app("Finder")/window[0]/button["Save"]`
- Test parsing paths with PID: `app(12345)/window[0]`
- Test parsing paths with nested children
- Test parsing invalid formats throws ElementPathError.invalidFormat
- Test parsing empty string throws ElementPathError.emptyPath

**Done when**:
- ElementPathTests.swift exists with parsing tests
- Tests cover success and error cases
- All tests pass
- Uses Swift Testing framework
- File is ≤100 lines

---

## S017: Test ElementPath Serialization and Round-Trip

**Intent**: Verify ElementPath serializes back to the same string it was parsed from.

**Work**:
- Add tests to `Tests/AccessibilityMCPTests/ElementReference/ElementPathTests.swift`
- Test serialization: `path.toString()` produces expected string
- Test round-trip: `ElementPath(parsing: path.toString()) == path`
- Test round-trip for various path formats (by name, by PID, by index, by title)

**Done when**:
- Serialization and round-trip tests exist
- All tests pass
- File remains ≤100 lines

---

## S018: Test ElementResolver Path Validation

**Intent**: Verify ElementResolver validates paths before walking.

**Work**:
- Create `Tests/AccessibilityMCPTests/ElementReference/ElementResolverTests.swift`
- Test resolution with invalid PID (≤0) throws ElementPathError.invalidPID
- Test resolution with excessively long path throws ElementPathError.pathTooLong
- Test resolution with empty path throws ElementPathError.emptyPath

**Done when**:
- ElementResolverTests.swift exists with validation tests
- Tests use MockAXBridge
- All tests pass
- Uses Swift Testing framework
- File is ≤100 lines

---

## S019: Test ElementResolver Path Resolution Success

**Intent**: Verify ElementResolver walks paths correctly and resolves to the right element.

**Work**:
- Add tests to `Tests/AccessibilityMCPTests/ElementReference/ElementResolverTests.swift`
- Create mock tree with MockAXBridge
- Test resolving `app("TestApp")/window[0]/button["Save"]` returns correct element
- Test resolving paths with multiple children
- Test resolving paths by index vs. by title

**Done when**:
- Path resolution success tests exist
- Tests use MockAXBridge with a controlled tree structure
- All tests pass
- File remains ≤100 lines (or split if needed)

---

## S020: Test ElementResolver Path Resolution Failures

**Intent**: Verify ElementResolver returns descriptive errors when components cannot be matched.

**Work**:
- Add tests to `Tests/AccessibilityMCPTests/ElementReference/ElementResolverTests.swift` (or new file if needed)
- Test resolving path with non-existent window index throws ElementPathError.componentNotFound with context
- Test resolving path with non-existent title throws error with available options
- Verify error messages include expected vs. actual (e.g., "Expected window 'Document1', found ['Untitled']")

**Done when**:
- Path resolution failure tests exist
- Error messages include expected and actual context
- Tests use MockAXBridge
- All tests pass
- File respects 100-line limit

---

## S021: Test ElementResolver Timeout Enforcement

**Intent**: Verify ElementResolver enforces timeout during resolution.

**Work**:
- Add tests to ElementResolverTests (or new file)
- Create mock with slow operations
- Test resolution with timeout=0.1 seconds throws ElementPathError.timeoutExceeded
- Test resolution with sufficient timeout succeeds

**Done when**:
- Timeout enforcement tests exist
- Tests use MockAXBridge with simulated delays
- All tests pass
- File respects 100-line limit

---

## S022: Test ElementFinder Search by Role

**Intent**: Verify ElementFinder finds elements matching role criteria.

**Work**:
- Create `Tests/AccessibilityMCPTests/ElementReference/ElementFinderTests.swift`
- Create mock tree with multiple roles using MockAXBridge
- Test search with role=.button returns all buttons
- Test search with role=.textField returns all text fields
- Verify returned elements include paths

**Done when**:
- ElementFinderTests.swift exists with role search tests
- Tests use MockAXBridge
- All tests pass
- Uses Swift Testing framework
- File is ≤100 lines

---

## S023: Test ElementFinder Search by Title

**Intent**: Verify ElementFinder finds elements matching title substring, case-insensitive by default.

**Work**:
- Add tests to `Tests/AccessibilityMCPTests/ElementReference/ElementFinderTests.swift`
- Test search with titleSubstring="Save" finds "Save", "Save As", "Autosave"
- Test case-insensitive matching: titleSubstring="save" finds "Save"
- Test case-sensitive matching: titleSubstring="Save", caseSensitive=true does NOT find "save"

**Done when**:
- Title search tests exist
- Case-insensitive matching works by default
- Case-sensitive matching works when enabled
- All tests pass
- File remains ≤100 lines

---

## S024: Test ElementFinder Search by Multiple Criteria

**Intent**: Verify ElementFinder handles searches with multiple criteria (AND logic).

**Work**:
- Add tests to ElementFinderTests
- Test search with role=.button AND titleSubstring="Save" returns only buttons with "Save" in title
- Test search with role, title, and identifier all specified

**Done when**:
- Multi-criteria search tests exist
- AND logic works correctly (all criteria must match)
- All tests pass
- File remains ≤100 lines

---

## S025: Test ElementFinder Result Limit Enforcement

**Intent**: Verify ElementFinder enforces maxResults limit.

**Work**:
- Add tests to ElementFinderTests
- Create mock tree with 50 buttons
- Test search with maxResults=20 returns exactly 20 results (no more)
- Test search with maxResults=100 on a tree with 50 matches returns 50 results

**Done when**:
- Result limit tests exist
- maxResults is enforced correctly
- All tests pass
- File remains ≤100 lines

---

## S026: Test Edge Cases and Empty Results

**Intent**: Verify all components handle edge cases gracefully.

**Work**:
- Add tests across all test files for edge cases:
  - TreeTraverser on empty tree (no children) returns single root node
  - ElementFinder with no matches returns empty array (not error)
  - ElementPath with only app component (no children) is valid
  - TreeTraverser on element with missing attributes handles gracefully

**Done when**:
- Edge case tests exist across all relevant test files
- Empty trees, missing attributes, and no-match searches handled gracefully
- All tests pass
- No force-unwrapping in production code exposed by edge case tests

---

## S027: Verify Swift 6 Compliance and Build

**Intent**: Ensure everything compiles cleanly under Swift 6 strict concurrency.

**Work**:
- Run `swift build` and verify zero warnings
- Run `swift test` and verify all tests pass
- Verify no force-unwrapping exists in production code (grep for `!` in Sources/)
- Verify all methods are ≤5 lines (manual review or script)
- Verify all types are ≤100 lines (manual review or script)
- Verify all throwing functions use typed throws
- Verify no C types (AXUIElement, CFString) leak above AXBridge layer

**Done when**:
- `swift build` succeeds with zero warnings
- `swift test` passes all tests
- No force-unwrapping in production code
- All Sandi Metz rules satisfied
- All laws satisfied
- All acceptance criteria met

---

## S028: Fix TreeTraverser+Helpers.swift Line Count Violation

**Intent**: Bring TreeTraverser+Helpers.swift into compliance with the 100-line limit (Sandi Metz rule).

**Work**:
- Extract 2-3 helper methods from TreeTraverser+Helpers.swift into a new extension file
- Create `Sources/AccessibilityMCP/TreeTraversal/TreeTraverser+PathBuilding.swift`
- Move path-related helper methods (buildPath, possibly buildChildren logic) to new file
- Ensure TreeTraverser+Helpers.swift is ≤100 lines

**Done when**:
- TreeTraverser+Helpers.swift is ≤100 non-blank, non-comment lines
- All existing tests pass
- No functionality changes
- File is ≤100 lines

---

## S029: Implement Timeout Enforcement in TreeTraverser

**Intent**: Enforce operation timeout on tree traversal per L17.

**Work**:
- Wrap TreeTraverser.traverse() logic with structured concurrency timeout
- Use Task.withTimeout or similar pattern with options.timeout value
- Throw TreeTraversalError.timeoutExceeded when timeout is exceeded
- Ensure all child traversal operations respect the timeout deadline

**Done when**:
- TreeTraverser throws TreeTraversalError.timeoutExceeded when timeout exceeded
- TreeTraverserTimeoutTests verify timeout enforcement works
- Tests verify that operations completing within timeout succeed
- All existing tests still pass

---

## S030: Implement Timeout Enforcement in ElementResolver

**Intent**: Enforce operation timeout on path resolution per L17.

**Work**:
- Wrap ElementResolver.resolve() logic with structured concurrency timeout
- Add timeout parameter to resolve() method or extract from path validation
- Throw ElementPathError.timeoutExceeded when timeout is exceeded
- Ensure all component resolution steps respect the timeout deadline

**Done when**:
- ElementResolver throws ElementPathError.timeoutExceeded when timeout exceeded
- ElementResolverTimeoutTests verify timeout enforcement works
- Tests verify that operations completing within timeout succeed
- All existing tests still pass
