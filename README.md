# Accessibility MCP Server

A macOS MCP server written in Swift that exposes the macOS Accessibility (AX) API to LLMs through the Model Context Protocol.

## Status

This project is in active development. The current version (0.1.0) provides read-only access to macOS Accessibility trees with four MCP tools for UI inspection.

## Requirements

- macOS 13.0 or later
- Swift 6

## Building

Build the project using Swift Package Manager:

```bash
swift build
```

## Running

Run the server from the build directory:

```bash
swift run accessibility-mcp
```

Or use the compiled binary:

```bash
.build/debug/accessibility-mcp
```

## Testing

Run the test suite:

```bash
swift test
```

## How It Works

This server uses the Model Context Protocol (MCP) to communicate with LLM clients like Claude Desktop over stdio transport. It provides structured, read-only access to any macOS application's UI through the Accessibility API.

## Accessibility Permissions

Before using this server, you must grant Accessibility permissions to the terminal or application running the server:

1. Open **System Settings** > **Privacy & Security** > **Accessibility**
2. Click the lock icon and authenticate
3. Add your terminal app (Terminal.app, iTerm2, etc.) to the allowed applications
4. Restart your terminal

Without these permissions, the server will return permission denied errors.

## MCP Tools

The server provides four read-only tools for inspecting application UI:

### get_ui_tree

Get the accessibility tree for an application with configurable depth limiting and filtering.

**Parameters:**
- `app` (required): Application name (e.g., "Finder") or numeric PID
- `depth` (optional): Maximum tree depth to traverse (default: 3, prevents overwhelming output)
- `include_attributes` (optional): Array of attribute names to include (not yet implemented)
- `filter_roles` (optional): Array of role names to filter by (not yet implemented)

**Returns:** JSON object with:
- `tree`: Hierarchical tree structure with role, title, value, children, actions, path, childCount, depth
- `hasMoreResults`: Boolean indicating if tree was truncated
- `resultCount`: Total number of nodes in the returned tree
- `depth`: The depth limit used

**Example:**
```json
{
  "app": "Finder",
  "depth": 2
}
```

**Response:**
```json
{
  "tree": {
    "role": "Application",
    "title": "Finder",
    "value": null,
    "children": [...],
    "actions": [],
    "path": "app(1234)",
    "childCount": 5,
    "depth": 0
  },
  "hasMoreResults": false,
  "resultCount": 42,
  "depth": 2
}
```

### find_element

Search for UI elements matching specific criteria within an application.

**Parameters:**
- `app` (required): Application name or PID
- `role` (optional): Element role to match (e.g., "Button", "TextField")
- `title` (optional): Title substring to match (case-insensitive)
- `value` (optional): Value to match
- `identifier` (optional): Accessibility identifier to match
- `max_results` (optional): Maximum results to return (default: 20)

**Returns:** JSON object with:
- `elements`: Array of matching elements with role, title, value, and path
- `hasMoreResults`: Boolean indicating if more results exist beyond the limit
- `resultCount`: Number of results returned

**Example:**
```json
{
  "app": "Finder",
  "role": "Button",
  "title": "Save",
  "max_results": 10
}
```

### get_focused_element

Get the currently focused UI element, either system-wide or within a specific application.

**Parameters:**
- `app` (optional): Application name or PID. If omitted, returns system-wide focused element.

**Returns:** JSON object with:
- `element`: Element info (role, title, value, path, actions) or null if no focus
- `hasFocus`: Boolean indicating whether any element has focus

**Example (system-wide):**
```json
{}
```

**Example (app-specific):**
```json
{
  "app": "Finder"
}
```

### list_windows

List all windows for an application or system-wide.

**Parameters:**
- `app` (optional): Application name or PID. If omitted, lists all windows system-wide.
- `include_minimized` (optional): Include minimized windows (default: false)

**Returns:** JSON object with:
- `windows`: Array of window info with title, position, size, minimized status, frontmost status, and owning app

**Example:**
```json
{
  "app": "Finder",
  "include_minimized": true
}
```

## Error Handling

All tools return structured errors with:
- `operation`: The tool name that failed
- `errorType`: Category of error (e.g., "app_not_running", "permission_denied", "timeout")
- `message`: Human-readable error description
- `app`: The application involved (if applicable)
- `guidance`: Actionable next steps to resolve the error

**Common errors:**
- **app_not_running**: The specified application is not currently running. Start the application and try again.
- **permission_denied**: Accessibility permissions not granted. See "Accessibility Permissions" section above.
- **timeout**: Operation exceeded time limit. Try reducing depth or narrowing search criteria.
- **invalid_parameter**: A parameter value is invalid (e.g., negative depth, zero maxResults).

## Limitations

Current limitations (to be addressed in future phases):
- Read-only access (no actions, no value setting)
- No element observation or change notifications
- Window position/size/minimized/frontmost detection is placeholder (returns default values)
- No application blocklist yet (will be added with write operations)
- No rate limiting (not needed for read-only operations)

## Safety

This version provides read-only access only. Future versions will add:
- Write operations with destructive action warnings
- Read-only mode flag to disable all mutations
- Application blocklist for security-sensitive apps
- Rate limiting for action execution

## Development

This project uses the Ushabti iterative agile agentic development framework. See `.ushabti/` for phase plans and progress.

## License

TBD
