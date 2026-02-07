# Phase 0003: Tree Traversal & Element Search

## Intent

Implement depth-limited tree traversal, tree serialization to JSON, and element search capabilities. This phase builds on the AXBridge from Phase 2 to provide the core query engine that will power read-only MCP tools in Phase 4.

The element referencing strategy is path-based: elements are identified by hierarchical paths (e.g., `app("Finder")/window[0]/toolbar/button["Save"]`) that are re-resolved on each operation. This approach is human-readable, LLM-friendly, and avoids stale reference issues.

This phase creates the query layer but does not wire MCP tools. The goal is to prove tree walking, path resolution, and search work in isolation before integrating with the MCP protocol.

## Scope

This phase MUST:
1. Create TreeNode — value type for serializable tree representation with fields: role, title, value, children, actions, path, childCount, depth
2. Create TreeTraversalOptions — configuration struct with maxDepth (required), filterRoles (optional Set<ElementRole>), includeAttributes (optional Set<ElementAttribute>), and timeout (TimeInterval)
3. Create TreeTraverser — depth-limited tree walking that returns TreeNode hierarchies
   - Accept TreeTraversalOptions for configuration
   - Enforce depth limits (no unbounded traversal)
   - Support role filtering (only include certain roles)
   - Support attribute filtering (control which attributes to include per node)
   - Enforce timeout on traversal operations
   - Return TreeNode hierarchy ready for JSON serialization
4. Create ElementPath — value type representing a path to an element
   - Support components: app (by name or PID), window (by index or title), child (by role with index or title disambiguation)
   - Parseable from string format: `app("Name")/window[0]/button["Save"]`
   - Serializable back to string (round-trip)
   - Equatable and Hashable
5. Create ElementPathComponent — enum representing individual path segments (appByName, appByPID, windowByIndex, windowByTitle, childByRole, childByRoleAndTitle)
6. Create ElementResolver — resolves ElementPath to live UIElement by walking the tree
   - Walk from application root through each path component
   - Match components by role, index, or title
   - Return descriptive errors if any component cannot be resolved (include expected vs. actual)
   - Validate paths before resolution (enforce maximum path length, validate PIDs)
   - Enforce timeouts on resolution operations
7. Create SearchCriteria — value type encapsulating search parameters (role, titleSubstring, value, identifier, caseSensitive flag)
8. Create ElementFinder — search for elements matching criteria within an application tree
   - Search by role, title (substring, case-insensitive by default), value, identifier
   - Return matching elements with their ElementPaths
   - Enforce maximum result limits (default: 20, configurable)
   - Use TreeTraverser internally to walk the tree
9. All tree operations go through AXBridge protocol (fully testable with MockAXBridge)
10. Write comprehensive tests for:
    - Tree traversal at various depths (verify depth limiting works)
    - Role and attribute filtering in tree traversal
    - ElementPath parsing, serialization, and round-tripping
    - Path resolution with success and failure cases
    - Element search with various criteria combinations
    - Edge cases: empty trees, deep nesting (exceeding max depth), missing attributes, stale paths, timeouts
11. All error types use typed throws with descriptive context

This phase MUST NOT:
- Wire any MCP tools (that is Phase 4)
- Implement action execution or value setting logic
- Implement observation/subscriptions
- Include any MCP protocol integration code

## Constraints

### Laws
- **L01**: Swift 6 language mode with strict concurrency enabled
- **L05**: Mandatory tree depth limiting — traversal MUST enforce max depth, default must be conservative (suggest 10)
- **L06**: Element reference validation — validate paths before resolution, structured errors for invalid/stale references
- **L13**: Mandatory result set limits for search operations
- **L17**: Operation timeout enforcement on traversal and resolution
- **L18**: Result limits documented and tested
- **L21**: All throwing functions use typed throws with explicit error types
- **L22**: Swift Testing framework for all tests
- **L23**: Every public method has at least one test
- **L27**: Unit tests use MockAXBridge, not real AX API
- **L38**: Element attribute type safety — handle type mismatches gracefully

### Style
- Sandi Metz rules: ≤100 lines per type, ≤5 lines per method, ≤4 parameters (use options structs for complex configuration)
- Prefer value types (struct, enum) for TreeNode, ElementPath, SearchCriteria
- Protocol-oriented programming where appropriate
- Functional patterns (map, filter, compactMap) for collection transformations
- No force-unwrapping in production code
- Descriptive error types with context (include what was expected vs. what was found)
- One type per file (TreeNode.swift, TreeTraverser.swift, ElementPath.swift, etc.)
- Group related files: TreeTraversal/, ElementReference/

## Acceptance Criteria

- TreeNode is a pure value type with all required fields (role, title, value, children, actions, path, childCount, depth)
- TreeNode conforms to Codable and serializes to clean JSON
- TreeTraversalOptions struct encapsulates all configuration (maxDepth, filterRoles, includeAttributes, timeout)
- TreeTraverser.traverse() accepts UIElement and TreeTraversalOptions, returns TreeNode
- Tree traversal enforces depth limits — trees deeper than maxDepth are truncated at the limit
- Tree traversal respects role filters — only nodes matching filterRoles are included if filter is set
- Tree traversal respects attribute filters — only requested attributes are populated if filter is set
- Tree traversal enforces timeout — operations exceeding timeout throw TimeoutError
- ElementPath parses from string format (e.g., `app("Finder")/window[0]/button["Save"]`)
- ElementPath serializes back to the same string format (round-trip)
- ElementPath is Equatable and Hashable (can be used in dictionaries/sets)
- ElementPathComponent enum covers all necessary component types (app, window, child with various disambiguation strategies)
- ElementResolver.resolve() accepts ElementPath and AXBridge, returns UIElement
- Path resolution validates paths before walking (max length, valid PID)
- Path resolution returns descriptive errors when components cannot be matched (e.g., "Expected window with title 'Document1', found windows: ['Untitled', 'README']")
- Path resolution enforces timeout
- SearchCriteria encapsulates search parameters (role, titleSubstring, value, identifier, caseSensitive)
- ElementFinder.find() accepts SearchCriteria, application UIElement, and AXBridge, returns array of (UIElement, ElementPath) tuples
- Element search enforces maximum result limit (configurable, default 20)
- Element search supports case-insensitive title matching by default (caseSensitive: false)
- Element search uses TreeTraverser internally for tree walking
- All public methods have tests using MockAXBridge (no real AX API dependency)
- All tests pass with Swift Testing framework
- Swift build succeeds with zero warnings under Swift 6 strict concurrency
- No force-unwrapping in production code
- All error types use typed throws
- No C types (AXUIElement, CFString) leak above AXBridge layer — all APIs use UIElement wrapper

## Risks / Notes

- **Path fragility**: Element paths are re-resolved on each call. If the UI changes between calls, resolution may fail. This is intentional — the LLM can re-query. Descriptive errors help the LLM understand what changed.
- **Performance on deep trees**: Large applications (browsers, Xcode) have enormous trees. Depth limiting is critical. Default maxDepth of 10 is conservative — tests should verify this prevents excessive traversal.
- **Case-insensitive matching**: Learned from Spotlight MCP. Default to case-insensitive title matching to improve robustness. Allow opt-in to case-sensitive for precision when needed.
- **Round-trip path fidelity**: ElementPath must serialize to the same string it was parsed from. This enables debugging and makes paths comprehensible to humans and LLMs.
- **Timeout enforcement**: AX operations can hang on unresponsive applications. Timeouts are essential. Use Task.withTimeout or similar structured concurrency patterns.
- **No MCP integration yet**: This phase proves the query engine works. MCP tool wiring happens in Phase 4 after this foundation is solid.
