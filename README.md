# Accessibility MCP Server

A macOS MCP server written in Swift that exposes the macOS Accessibility (AX) API to LLMs through the Model Context Protocol.

## Status

This project is in active development. The current version (0.1.0) provides read, write, and observe access to macOS Accessibility trees with seven MCP tools: four for UI inspection, two for UI automation, and one for monitoring UI changes. Write operations are protected by read-only mode, application blocklist, and rate limiting.

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

**Run in read-only mode** (disables write operations):

```bash
swift run accessibility-mcp --read-only
```

Or using environment variable:

```bash
ACCESSIBILITY_MCP_READ_ONLY=1 swift run accessibility-mcp
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

The server provides seven MCP tools: four read-only tools for inspecting application UI, one observation tool for monitoring UI changes, and two write tools for UI automation.

### Read-Only Tools

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

### Observation Tools

Observation tools are available in both normal and read-only modes since they are passive listeners that do not modify UI state.

### observe_changes

Watch for UI change events in an application for a specified duration. Events are collected and returned as a batch when the observation period ends.

**Parameters:**
- `app` (required): Application name or PID
- `events` (optional): Array of event types to watch. If omitted, all event types are monitored. Valid types:
  - `value_changed` - Element value changed (text fields, sliders, etc.)
  - `focus_changed` - Focus moved to a different element
  - `window_created` - A new window was created
  - `window_destroyed` - A window was closed
  - `title_changed` - An element's title changed
- `element_path` (optional): Path to a specific element to observe. If omitted, observes the entire application.
- `duration` (optional): Observation duration in seconds (default: 30, max: 300). Values beyond max are silently clamped.

**Returns:** JSON object with:
- `events`: Array of collected events, each containing:
  - `timestamp`: ISO 8601 timestamp of the event
  - `eventType`: Type of change detected
  - `elementRole`: Role of the affected element (if available)
  - `elementTitle`: Title of the affected element (if available)
  - `elementPath`: Path to the affected element (if determinable)
  - `newValue`: New value after the change (if applicable)
- `totalEventsCollected`: Total number of events seen
- `eventsReturned`: Number of events in the response
- `truncated`: Whether events were truncated at the 1000-event limit
- `durationRequested`: The observation duration used
- `durationActual`: Actual elapsed time
- `applicationTerminated`: Whether the app quit during observation
- `notes`: Array of informational messages (clamping, truncation, etc.)

**Example:**
```json
{
  "app": "TextEdit",
  "events": ["value_changed", "title_changed"],
  "duration": 10
}
```

**Response:**
```json
{
  "events": [
    {
      "timestamp": "2026-02-07T18:30:00Z",
      "eventType": "value_changed",
      "elementRole": "AXTextArea",
      "elementTitle": null,
      "elementPath": null,
      "newValue": null
    },
    {
      "timestamp": "2026-02-07T18:30:01Z",
      "eventType": "title_changed",
      "elementRole": "AXWindow",
      "elementTitle": "Untitled",
      "elementPath": null,
      "newValue": null
    }
  ],
  "totalEventsCollected": 2,
  "eventsReturned": 2,
  "truncated": false,
  "durationRequested": 10,
  "durationActual": 10.003,
  "applicationTerminated": false,
  "notes": []
}
```

**Limitations:**
- Events are batched and returned at the end of the duration (not streamed in real-time)
- Maximum 1000 events per observation (excess events are dropped with a truncation note)
- Maximum duration is 300 seconds (5 minutes)
- The MCP tool call blocks for the entire duration
- If the observed application terminates, events collected so far are returned with `applicationTerminated: true`

### Write Tools

Write tools are disabled when running in read-only mode (`--read-only` flag or `ACCESSIBILITY_MCP_READ_ONLY=1` env var).

### perform_action

Perform an accessibility action on a UI element (press button, select menu, etc.).

**Parameters:**
- `app` (required): Application name or PID
- `elementPath` (required): Element path from find_element or get_ui_tree (e.g., "app(1234)/window[0]/button[@title='OK']")
- `action` (required): Action name. Supported actions:
  - `AXPress` - Press a button or activate an element
  - `AXPick` - Pick/select an item (menus, lists)
  - `AXShowMenu` - Show a context menu
  - `AXConfirm` - Confirm a dialog
  - `AXCancel` - Cancel a dialog
  - `AXRaise` - Bring a window to front
  - `AXIncrement` - Increment a value (stepper, slider)
  - `AXDecrement` - Decrement a value (stepper, slider)

**Returns:** JSON object with:
- `success`: Boolean indicating success
- `action`: The action that was performed
- `elementState`: Post-action element state (role, title, value, enabled, focused, actions, path)
- `rateLimitWarning`: Optional warning if rate limit was applied

**Example:**
```json
{
  "app": "Finder",
  "elementPath": "app(1234)/window[0]/button[@title='Close']",
  "action": "AXPress"
}
```

**Response:**
```json
{
  "success": true,
  "action": "AXPress",
  "elementState": {
    "role": "AXButton",
    "title": "Close",
    "value": null,
    "enabled": true,
    "focused": false,
    "actions": ["AXPress"],
    "path": "app(1234)/window[0]/button[@title='Close']"
  },
  "rateLimitWarning": null
}
```

**Safety checks:**
- Blocked in read-only mode
- Blocked for applications on blocklist (Terminal, iTerm2, System Settings, Keychain Access by default)
- Rate limited (default: 10 actions/second)
- Returns post-action state for verification

### set_value

Set the value of a UI element (text field, checkbox, slider, etc.).

**Parameters:**
- `app` (required): Application name or PID
- `elementPath` (required): Element path from find_element or get_ui_tree
- `value` (required): Value to set. Type depends on element:
  - String for text fields
  - Boolean (true/false) for checkboxes
  - Number for sliders, steppers, number fields

**Returns:** JSON object with:
- `success`: Boolean indicating success
- `previousValue`: The value before the change (string or null)
- `newValue`: The value after the change (string or null)
- `elementState`: Post-change element state
- `rateLimitWarning`: Optional warning if rate limit was applied

**Example (text field):**
```json
{
  "app": "TextEdit",
  "elementPath": "app(1234)/window[0]/textfield[0]",
  "value": "Hello, world!"
}
```

**Example (checkbox):**
```json
{
  "app": "Safari",
  "elementPath": "app(5678)/window[0]/checkbox[@title='Enable JavaScript']",
  "value": true
}
```

**Example (slider):**
```json
{
  "app": "Music",
  "elementPath": "app(9012)/window[0]/slider[@title='Volume']",
  "value": 75
}
```

**Response:**
```json
{
  "success": true,
  "previousValue": "Hello",
  "newValue": "Hello, world!",
  "elementState": {
    "role": "AXTextField",
    "title": null,
    "value": "Hello, world!",
    "enabled": true,
    "focused": true,
    "actions": [],
    "path": "app(1234)/window[0]/textfield[0]"
  },
  "rateLimitWarning": null
}
```

**Safety checks:**
- Blocked in read-only mode
- Blocked for applications on blocklist
- Rate limited (default: 10 actions/second)
- Automatic value type coercion based on JSON type
- Returns previous and new values for verification

## Safety Features

### Read-Only Mode

Disable all write operations while preserving read access. Useful for safe exploration or when automation is not needed.

**Enable via CLI flag:**
```bash
swift run accessibility-mcp --read-only
```

**Enable via environment variable:**
```bash
ACCESSIBILITY_MCP_READ_ONLY=1 swift run accessibility-mcp
```

When enabled:
- `perform_action` and `set_value` are hidden from the tool list
- Attempting to call write tools returns a structured error with guidance
- All read-only tools continue to work normally

### Application Blocklist

Prevent write operations on security-sensitive applications. Read operations are always permitted.

**Default blocklist:**
- Keychain Access (`com.apple.keychainaccess`)
- Terminal (`com.apple.Terminal`)
- iTerm2 (`com.googlecode.iterm2`)
- System Settings (`com.apple.systempreferences`)

**Add custom apps to blocklist:**
```bash
ACCESSIBILITY_MCP_BLOCKLIST="com.example.app1,com.example.app2" swift run accessibility-mcp
```

Custom apps are merged with the default blocklist. Use bundle identifiers, not app names.

When a blocklisted app is targeted:
- Write operations return a structured error: "Application 'X' is blocklisted for write operations"
- Read operations continue to work
- Error includes guidance directing users to the configuration

### Rate Limiting

Prevent runaway automation loops by limiting write operations per second.

**Default:** 10 actions per second

**Configure custom limit:**
```bash
ACCESSIBILITY_MCP_RATE_LIMIT=5 swift run accessibility-mcp
```

When rate limit is exceeded:
- The operation is **delayed** (not rejected)
- A warning is included in the response: "Rate limit reached. Delayed 0.123s"
- This allows controlled bursts while preventing infinite loops

## Configuration Reference

| Environment Variable | CLI Flag | Default | Description |
|---------------------|----------|---------|-------------|
| `ACCESSIBILITY_MCP_READ_ONLY` | `--read-only` | `false` | Disable write operations |
| `ACCESSIBILITY_MCP_RATE_LIMIT` | - | `10` | Max write operations per second |
| `ACCESSIBILITY_MCP_BLOCKLIST` | - | (see below) | Comma-separated bundle IDs to block |

**Default blocklist:** `com.apple.keychainaccess,com.apple.Terminal,com.googlecode.iterm2,com.apple.systempreferences`

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
- **read_only_mode**: Write operation attempted in read-only mode. Remove `--read-only` flag or `ACCESSIBILITY_MCP_READ_ONLY` env var.
- **blocklisted_application**: Write operation attempted on blocklisted app. Read operations are still permitted.
- **action_not_supported**: The requested action is not supported by the target element. Use `get_ui_tree` or `find_element` to check available actions.
- **element_path_error**: Element path is invalid or element not found. Check path syntax and ensure element exists.
- **observer_creation_failed**: Failed to create accessibility observer. Ensure permissions are granted.
- **application_terminated**: Observed application terminated during observation. Partial results may be returned.

## Limitations

Current limitations (to be addressed in future phases):
- Observation uses a batch model (events returned at end of duration, not streamed in real-time)
- Window position/size/minimized/frontmost detection is placeholder (returns default values)
- No interactive confirmation dialogs (MCP protocol limitation)
- Write operations cannot be undone - use with caution

## Important Notes on Write Operations

**Actions have real side effects.** `perform_action` and `set_value` modify application state just like user interaction. This includes:
- Closing windows and dialogs
- Deleting or modifying content
- Executing commands
- Changing settings

**Always verify intent before automating actions.** Use the agency loop:
1. Find the element with `find_element` or `get_ui_tree`
2. Perform the action with `perform_action` or `set_value`
3. Verify the outcome using the returned `elementState`

**Use read-only mode for safe exploration.** When you only need to inspect UI, not modify it, enable read-only mode to prevent accidental changes.

## Development

This project uses the Ushabti iterative agile agentic development framework. See `.ushabti/` for phase plans and progress.

## License

TBD
