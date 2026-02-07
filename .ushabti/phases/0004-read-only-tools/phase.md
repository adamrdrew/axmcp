# Phase 0004: Read-Only MCP Tools

## Intent

Wire up the four read-only MCP tools to make the server usable for UI inspection through Claude Desktop. This phase connects the engine built in Phases 2 and 3 (AX Bridge, TreeTraverser, ElementFinder, ElementPath, ElementResolver) to the MCP protocol layer by defining tool schemas, implementing tool handlers, and registering them with the server.

After this phase, an LLM can inspect any app's UI tree, find specific elements, check what's focused, and list windows. This is the first phase where the server becomes genuinely useful.

This phase focuses exclusively on read operations. Write operations (perform_action, set_value) are deferred to Phase 5.

## Scope

This phase MUST:
1. Define MCP tool schemas for all four read-only tools:
   - `get_ui_tree`: Returns the accessibility tree for an application with depth limiting and optional filtering
     - Parameters: app (required, string or PID), depth (optional, default 3), include_attributes (optional, array of attribute names), filter_roles (optional, array of roles)
   - `find_element`: Searches for elements matching criteria within an application
     - Parameters: app (required), role (optional), title (optional), value (optional), identifier (optional), max_results (optional, default 20)
   - `get_focused_element`: Returns the currently focused element
     - Parameters: app (optional, system-wide if omitted)
   - `list_windows`: Lists all windows for an app or system-wide
     - Parameters: app (optional, all apps if omitted), include_minimized (optional, default false)
2. Implement tool handlers that:
   - Parse and validate input parameters
   - Resolve app by name (find running process) or by PID
   - Call the appropriate engine methods (TreeTraverser, ElementFinder, etc.)
   - Return structured JSON responses
   - Handle errors gracefully with descriptive messages including context (operation, app, error type, guidance)
3. Implement application resolution: given an app name like "Finder" or "Safari", find the running process and get its PID
4. Wire all four tools to the MCP server's tool registry
5. Ensure all responses are structured JSON with consistent schemas
6. Implement pagination for get_ui_tree and find_element when results exceed size limits
7. Implement timeouts on all operations (enforced by L17)
8. Write tests for:
   - Tool parameter parsing and validation
   - App name resolution (app name → PID)
   - Tool handler integration (mock AX bridge → tool response)
   - Error cases (app not found, app not running, permissions denied, timeout, invalid parameters)
   - Pagination behavior
   - Timeout behavior
   - JSON response schema consistency

This phase MUST NOT:
- Implement write tools (perform_action, set_value) — deferred to Phase 5
- Implement observation tools (observe_changes) — deferred to Phase 6
- Implement safety features specific to write operations (not needed yet)
- Implement application blocklist (deferred until write operations exist)
- Implement rate limiting (only needed for write operations)

## Constraints

### Laws
- **L04**: Explicit application scope required — app parameter must be required for get_ui_tree and find_element, optional (with clear scoping semantics) for get_focused_element and list_windows
- **L05**: Mandatory tree depth limiting — get_ui_tree must enforce max depth with conservative default (3 levels per spec, configurable)
- **L06**: Element reference validation — validate element paths before resolution in future phases (not applicable to this phase as we return paths, not resolve them)
- **L07**: Accessibility permission detection and handling — return structured errors when permissions denied
- **L12**: Structured JSON responses only — all tool responses return structured JSON with consistent schemas
- **L13**: Mandatory result set limits — enforce max results for find_element (default 20) and consider limits for get_ui_tree node count
- **L17**: Operation timeout enforcement — all operations must enforce timeouts to prevent hanging on unresponsive apps
- **L18**: Result limits documented and tested — verify limit enforcement in tests
- **L21**: Typed throws for all error-throwing functions
- **L22**: Swift Testing framework for all tests
- **L23**: Every public method must have at least one test
- **L27**: Unit tests use MockAXBridge, not real AX API
- **L37**: Error context preservation — errors must include operation, app, error type, and actionable guidance

### Style
- Sandi Metz rules: ≤100 lines per type, ≤5 lines per method, ≤4 parameters (use parameter objects/structs for complex configuration)
- Protocol-oriented programming for tool handler abstraction
- Dependency injection (inject AXBridge, TreeTraverser, ElementFinder, etc. into tool handlers)
- No force-unwrapping in production code
- Descriptive error types with context
- One type per file
- Files grouped in Tools/ directory
- Functional patterns for collection transformations

## Acceptance Criteria

- All four read-only tools appear in the MCP tool list returned to clients
- Tool schemas are correctly defined with required and optional parameters matching the spec
- Tool handlers parse and validate parameters correctly:
  - Required parameters missing → structured error
  - Invalid parameter types → structured error
  - Invalid parameter values (negative depth, etc.) → structured error
- App resolution works correctly:
  - App name like "Finder" or "Safari" resolves to running process PID
  - Numeric PID values are accepted directly
  - App not running → structured error with guidance ("Application 'Foo' is not running")
  - Multiple matches → structured error or deterministic selection strategy
- get_ui_tree returns structured JSON with:
  - Tree hierarchy matching TreeNode structure
  - Depth limiting enforced (default 3, configurable)
  - Role filtering applied when specified
  - Attribute filtering applied when specified
  - Pagination markers if tree is truncated
- find_element returns structured JSON with:
  - Array of matching elements with element paths
  - Result limit enforced (default 20, configurable)
  - Case-insensitive title matching by default
  - Empty array when no matches found (not an error)
- get_focused_element returns structured JSON with:
  - Focused element with full attribute set and path
  - Works system-wide when app not specified
  - Works within specific app when app specified
  - Returns structured response when no element focused (not an error)
- list_windows returns structured JSON with:
  - Array of windows with title, position, size, minimized status, frontmost status, owning app
  - Works system-wide when app not specified
  - Works within specific app when app specified
  - Respects include_minimized parameter
- All errors return structured JSON with:
  - operation (tool name)
  - error_type (descriptive error category)
  - message (human-readable description)
  - app (if applicable)
  - guidance (actionable next steps when possible)
- Timeouts are enforced on all operations — operations exceeding timeout return timeout errors
- Tests verify:
  - Parameter parsing and validation
  - App resolution (name → PID)
  - Tool responses match expected JSON schemas
  - Error cases (app not found, permissions denied, timeout, invalid params)
  - Pagination behavior
  - Timeout enforcement
- All tests pass using MockAXBridge (no real AX API dependency)
- Swift build succeeds with zero warnings under Swift 6 strict concurrency
- No force-unwrapping in production code
- README updated with tool documentation and usage examples

## Risks / Notes

- **App name ambiguity**: Multiple apps with similar names could exist (e.g., "Safari" vs "Safari Technology Preview"). Strategy: exact match preferred, or return error listing matches. Document behavior clearly.
- **System-wide operations**: list_windows and get_focused_element can operate system-wide (no app specified). This is acceptable per L04 exception for focused element and window listing.
- **Pagination complexity**: Implementing full continuation-token pagination is complex. Acceptable initial approach: truncate with hasMoreResults flag and guidance to narrow scope. Full pagination can be added later if needed.
- **Timeout values**: Need reasonable defaults. Suggest: 5s for tree traversal, 2s for element search, 1s for focused element and window listing. Make configurable.
- **Permission errors**: AXBridge already handles permission detection (Phase 2). Tool handlers must surface permission errors with actionable guidance from L07.
- **No write operations yet**: This phase is read-only. Write operations come in Phase 5 after read capabilities are proven stable.
- **No blocklist yet**: Application blocklist (L09) is deferred until write operations exist (Phase 5), as read-only access poses minimal security risk.
