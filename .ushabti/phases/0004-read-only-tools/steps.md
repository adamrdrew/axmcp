# Implementation Steps

## S001: App Resolution Service

**Intent**: Provide a service that resolves application names to running process PIDs.

**Work**:
- Create AppResolver protocol with method: `resolve(appIdentifier: String) throws(AppResolutionError) -> pid_t`
- Create LiveAppResolver that uses NSWorkspace.shared.runningApplications to find apps by name or bundle identifier
- Accept numeric strings as direct PID values
- Handle app not running, multiple matches, and invalid identifiers
- Create MockAppResolver for testing
- Define AppResolutionError enum with cases: notRunning, multipleMatches, invalidIdentifier

**Done when**:
- AppResolver protocol defined
- LiveAppResolver implementation compiles and resolves app names to PIDs using NSWorkspace
- Tests verify app name resolution, PID pass-through, and error cases

## S002: Tool Parameter Structs

**Intent**: Define parameter structs for each tool to avoid exceeding 4-parameter limit and enable clean validation.

**Work**:
- Create GetUITreeParameters struct with: app (String), depth (Int?, default 3), includeAttributes ([String]?), filterRoles ([String]?)
- Create FindElementParameters struct with: app (String), role (String?), title (String?), value (String?), identifier (String?), maxResults (Int?, default 20)
- Create GetFocusedElementParameters struct with: app (String?)
- Create ListWindowsParameters struct with: app (String?), includeMinimized (Bool?, default false)
- All parameter structs conform to Codable for MCP JSON parsing
- Add validation methods to each struct (e.g., depth must be > 0, maxResults must be > 0)

**Done when**:
- All four parameter structs defined and Codable
- Validation methods added and tested
- Tests verify parsing from JSON and validation logic

## S003: Tool Response Structs

**Intent**: Define structured response types for each tool to ensure consistent JSON schema output.

**Work**:
- Create UITreeResponse struct with: tree (TreeNode), hasMoreResults (Bool), resultCount (Int), depth (Int)
- Create FindElementResponse struct with: elements ([ElementMatch]), hasMoreResults (Bool), resultCount (Int) where ElementMatch contains element info and path
- Create FocusedElementResponse struct with: element (optional ElementInfo), hasFocus (Bool)
- Create ListWindowsResponse struct with: windows ([WindowInfo]) where WindowInfo contains title, position, size, minimized, frontmost, app
- Create ToolError struct with: operation (String), errorType (String), message (String), app (String?), guidance (String?)
- All response structs conform to Codable for JSON serialization

**Done when**:
- All response structs defined and Codable
- Response structs serialize to clean JSON matching expected schemas
- Tests verify JSON serialization produces expected structure

## S004: get_ui_tree Tool Handler

**Intent**: Implement the get_ui_tree tool handler that returns the accessibility tree for an application.

**Work**:
- Create GetUITreeHandler that accepts GetUITreeParameters
- Inject dependencies: AppResolver, AXBridge, TreeTraverser
- Resolve app identifier to PID using AppResolver
- Create application UIElement using AXBridge
- Configure TreeTraversalOptions from parameters (maxDepth, filterRoles, includeAttributes, timeout)
- Call TreeTraverser.traverse() to get tree
- Build UITreeResponse with tree, hasMoreResults flag, result count, depth
- Handle errors and convert to ToolError responses with context
- Enforce timeout (default 5s, configurable)

**Done when**:
- GetUITreeHandler implemented with dependency injection
- Handler resolves app, calls TreeTraverser, returns UITreeResponse
- Tests verify correct tree retrieval with various parameter combinations
- Tests verify error handling (app not found, permissions denied, timeout)

## S005: find_element Tool Handler

**Intent**: Implement the find_element tool handler that searches for elements matching criteria.

**Work**:
- Create FindElementHandler that accepts FindElementParameters
- Inject dependencies: AppResolver, AXBridge, ElementFinder
- Resolve app identifier to PID using AppResolver
- Create application UIElement using AXBridge
- Build SearchCriteria from parameters (role, titleSubstring, value, identifier, caseSensitive default false)
- Call ElementFinder.find() with criteria and max results limit
- Build FindElementResponse with matching elements and paths
- Set hasMoreResults flag if results were truncated
- Handle errors and convert to ToolError responses with context
- Enforce timeout (default 2s, configurable)

**Done when**:
- FindElementHandler implemented with dependency injection
- Handler resolves app, calls ElementFinder, returns FindElementResponse
- Tests verify element search with various criteria combinations
- Tests verify result limiting and hasMoreResults flag
- Tests verify error handling

## S006: get_focused_element Tool Handler

**Intent**: Implement the get_focused_element tool handler that returns the currently focused element.

**Work**:
- Create GetFocusedElementHandler that accepts GetFocusedElementParameters
- Inject dependencies: AppResolver (optional, only if app specified), AXBridge
- If app specified: resolve to PID, get application element, query its focused child
- If app not specified: use system-wide element, query focused element
- Build FocusedElementResponse with element info and hasFocus flag
- Handle case where no element is focused (valid state, not an error)
- Handle errors and convert to ToolError responses with context
- Enforce timeout (default 1s, configurable)

**Done when**:
- GetFocusedElementHandler implemented
- Handler works both system-wide and app-specific
- Handler correctly represents "no focus" state without error
- Tests verify both modes and error cases

## S007: list_windows Tool Handler

**Intent**: Implement the list_windows tool handler that lists windows for an app or system-wide.

**Work**:
- Create ListWindowsHandler that accepts ListWindowsParameters
- Inject dependencies: AppResolver (optional), AXBridge
- If app specified: resolve to PID, get application element, enumerate its windows
- If app not specified: use system-wide element or enumerate all running apps and their windows
- For each window, extract: title, position (AXPosition), size (AXSize), minimized status, frontmost status, owning app name
- Filter out minimized windows if includeMinimized is false
- Build ListWindowsResponse with window info array
- Handle errors and convert to ToolError responses with context
- Enforce timeout (default 1s, configurable)

**Done when**:
- ListWindowsHandler implemented
- Handler works both system-wide and app-specific
- Handler respects includeMinimized parameter
- Tests verify window listing and filtering

## S008: MCP Tool Schema Definitions

**Intent**: Define MCP tool schemas that declare parameters and return types for the MCP protocol.

**Work**:
- Define tool schema for get_ui_tree with parameters: app (string, required), depth (number, optional), include_attributes (array, optional), filter_roles (array, optional)
- Define tool schema for find_element with parameters: app (string, required), role (string, optional), title (string, optional), value (string, optional), identifier (string, optional), max_results (number, optional)
- Define tool schema for get_focused_element with parameters: app (string, optional)
- Define tool schema for list_windows with parameters: app (string, optional), include_minimized (boolean, optional)
- All schemas include descriptions for each parameter and the tool itself
- Schemas specify required vs optional parameters correctly

**Done when**:
- All four tool schemas defined in MCP format
- Schemas accurately reflect parameter requirements
- Schemas include clear descriptions

## S009: Wire Tools to MCP Server

**Intent**: Register all four tool handlers with the MCP server so they appear in the tool list and respond to invocations.

**Work**:
- In server initialization, instantiate all dependencies (AppResolver, AXBridge, TreeTraverser, ElementFinder)
- Instantiate all four tool handlers with injected dependencies
- Register each tool handler with the MCP server using tool schemas from S008
- Map tool invocations to handler methods
- Ensure tool list returns all four tools with correct schemas
- Wire error handling so all exceptions convert to ToolError JSON responses

**Done when**:
- All four tools registered with MCP server
- Tool list request returns all four tools with correct schemas
- Tool invocation requests route to correct handlers
- Handlers execute and return JSON responses

## S010: Integration Tests

**Intent**: Verify end-to-end tool behavior with mocked dependencies.

**Work**:
- Write integration tests that instantiate tool handlers with MockAXBridge and MockAppResolver
- Test get_ui_tree with various depth and filter parameters, verify JSON response structure
- Test find_element with various search criteria, verify result limiting and pagination flags
- Test get_focused_element both system-wide and app-specific
- Test list_windows both system-wide and app-specific, verify filtering
- Test all error cases: app not found, app not running, permissions denied, timeout exceeded, invalid parameters
- Verify all responses conform to expected JSON schemas
- Verify timeout enforcement for all tools
- Verify ToolError responses include correct context fields

**Done when**:
- Integration tests cover all four tools with success and error cases
- All tests pass with MockAXBridge (no real AX API dependency)
- Tests verify JSON response schema conformance
- Tests verify timeout enforcement

## S011: Update README with Tool Documentation

**Intent**: Document all four tools with parameter descriptions and usage examples for users.

**Work**:
- Add "MCP Tools" section to README.md
- For each tool, document:
  - Purpose and use case
  - Parameters (required/optional, types, defaults)
  - Return value structure
  - Example usage from Claude Desktop or MCP client
  - Common error cases and guidance
- Include example JSON responses
- Document default timeout values and how to interpret timeout errors
- Document app resolution behavior (name vs PID)

**Done when**:
- README.md contains comprehensive tool documentation
- Each tool has parameter reference and example usage
- Example JSON responses are accurate
- Documentation is clear and actionable for users

## S012: Extract Error Conversion Utility

**Intent**: Eliminate code duplication in tool handlers by extracting shared error conversion logic to a centralized utility, bringing all handlers under the 100-line Sandi Metz limit.

**Work**:
- Create ErrorConverter utility struct in Tools/ directory
- Move error conversion methods from handlers to ErrorConverter:
  - convertAppError(AppResolutionError, operation: String) -> ToolExecutionError
  - convertParameterError(ToolParameterError, operation: String) -> ToolExecutionError
  - convertAccessibilityError(AccessibilityError, operation: String, app: String?) -> ToolExecutionError
  - convertTraversalError(TreeTraversalError, operation: String, app: String) -> ToolExecutionError
- Update all four handlers (GetUITreeHandler, FindElementHandler, GetFocusedElementHandler, ListWindowsHandler) to use ErrorConverter
- Remove duplicate error conversion methods from handlers
- Verify all handlers are under 100 lines (excluding blanks and comments)
- Run tests to ensure no regressions

**Done when**:
- ErrorConverter utility created and tested
- All four handlers use ErrorConverter instead of duplicate methods
- All handlers are under 100 lines
- All tests pass with no changes to test behavior
- Build succeeds with zero warnings
