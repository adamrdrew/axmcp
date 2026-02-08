# Accessibility MCP Server

An MCP server that lets Claude (or any LLM) see and interact with macOS applications through the Accessibility API. It can read UI trees, find elements, click buttons, type text, and watch for changes.

## Quick Start

**Three steps to get running with Claude Desktop:**

### Step 1: Build it

```bash
git clone https://github.com/adamrdrew/macos-accessibility-mcp.git
cd macos-accessibility-mcp
swift build -c release
```

### Step 2: Tell Claude Desktop about it

Open this file in a text editor:

```
~/Library/Application Support/Claude/claude_desktop_config.json
```

If the file doesn't exist, create it. Add this (replace the path with where you cloned the repo):

```json
{
  "mcpServers": {
    "accessibility": {
      "command": "/Users/YOURUSERNAME/macos-accessibility-mcp/.build/release/accessibility-mcp"
    }
  }
}
```

Save the file and restart Claude Desktop.

### Step 3: Grant Accessibility permissions

The first time you use it, macOS will ask for permission. If it doesn't, do it manually:

1. Open **System Settings**
2. Go to **Privacy & Security** > **Accessibility**
3. Click the **+** button
4. Add **Claude Desktop** (find it in /Applications)
5. Restart Claude Desktop

That's it. Open Claude Desktop and ask it something like:

> "What windows do I have open right now?"

or

> "Look at the Finder UI and describe what you see."

Claude will use the accessibility tools automatically.

---

## What Can It Do?

| Tool | What it does | Example prompt |
|------|-------------|----------------|
| `get_ui_tree` | See an app's UI hierarchy | "Show me the UI tree for Finder" |
| `find_element` | Find specific buttons, fields, etc. | "Find all buttons in Safari" |
| `get_focused_element` | See what's currently focused | "What element has focus right now?" |
| `list_windows` | List open windows | "What windows are open?" |
| `perform_action` | Click buttons, select menus | "Click the Close button in Finder" |
| `set_value` | Type text, toggle checkboxes | "Type 'hello' in the search field" |
| `observe_changes` | Watch for UI changes | "Watch TextEdit for changes for 10 seconds" |

You don't need to call these tools directly. Just describe what you want in natural language and Claude figures out which tools to use.

## Installation

### Homebrew

```bash
brew tap adamrdrew/accessibility-mcp
brew install accessibility-mcp
```

If you install via Homebrew, your Claude Desktop config is simpler:

```json
{
  "mcpServers": {
    "accessibility": {
      "command": "accessibility-mcp"
    }
  }
}
```

### Building from Source

Requires macOS 13.0+ and Swift 6.

```bash
git clone https://github.com/adamrdrew/macos-accessibility-mcp.git
cd macos-accessibility-mcp
swift build -c release
```

The binary will be at `.build/release/accessibility-mcp`.

## Safety Features

Write operations (clicking, typing) have safety guards built in:

**Read-only mode** disables all write operations:

```json
{
  "mcpServers": {
    "accessibility": {
      "command": "accessibility-mcp",
      "args": ["--read-only"]
    }
  }
}
```

**Application blocklist** prevents writes to sensitive apps. By default, Terminal, iTerm2, System Settings, and Keychain Access are blocked. Reads still work on blocked apps.

**Rate limiting** prevents runaway automation (default: 10 actions/second).

### Configuration

| Environment Variable | CLI Flag | Default | Description |
|---------------------|----------|---------|-------------|
| `ACCESSIBILITY_MCP_READ_ONLY` | `--read-only` | `false` | Disable write operations |
| `ACCESSIBILITY_MCP_RATE_LIMIT` | - | `10` | Max write operations per second |
| `ACCESSIBILITY_MCP_BLOCKLIST` | - | (see above) | Comma-separated bundle IDs to block for writes |

Example with custom config:

```json
{
  "mcpServers": {
    "accessibility": {
      "command": "accessibility-mcp",
      "env": {
        "ACCESSIBILITY_MCP_RATE_LIMIT": "5",
        "ACCESSIBILITY_MCP_BLOCKLIST": "com.example.app1,com.example.app2"
      }
    }
  }
}
```

## MCP Tools Reference

### get_ui_tree

Get the accessibility tree for an application.

**Parameters:**
- `app` (required): Application name (e.g., "Finder") or numeric PID
- `depth` (optional): Maximum tree depth (default: 3)

**Returns:** Hierarchical tree with role, title, value, children, actions, and element paths.

**Example request:**
```json
{ "app": "Finder", "depth": 2 }
```

### find_element

Search for UI elements matching criteria.

**Parameters:**
- `app` (required): Application name or PID
- `role` (optional): Element role (e.g., "Button", "TextField")
- `title` (optional): Title substring to match (case-insensitive)
- `max_results` (optional): Maximum results (default: 20)

**Example request:**
```json
{ "app": "Finder", "role": "Button", "title": "Save" }
```

### get_focused_element

Get the currently focused UI element.

**Parameters:**
- `app` (optional): Application name or PID. Omit for system-wide focus.

**Example request:**
```json
{}
```

### list_windows

List windows for an application or system-wide.

**Parameters:**
- `app` (optional): Application name or PID. Omit for all windows.

**Example request:**
```json
{ "app": "Finder" }
```

### perform_action

Click buttons, select menu items, and perform other UI actions.

**Parameters:**
- `app` (required): Application name or PID
- `elementPath` (required): Element path from `get_ui_tree` or `find_element`
- `action` (required): Action name (`AXPress`, `AXPick`, `AXShowMenu`, `AXConfirm`, `AXCancel`, `AXRaise`, `AXIncrement`, `AXDecrement`)

**Example request:**
```json
{
  "app": "Finder",
  "elementPath": "app(1234)/window[0]/button[@title='Close']",
  "action": "AXPress"
}
```

Returns post-action element state so you can verify the action worked.

### set_value

Set the value of text fields, checkboxes, sliders, etc.

**Parameters:**
- `app` (required): Application name or PID
- `elementPath` (required): Element path from `get_ui_tree` or `find_element`
- `value` (required): Value to set (string, boolean, or number depending on element)

**Example request:**
```json
{
  "app": "TextEdit",
  "elementPath": "app(1234)/window[0]/textfield[0]",
  "value": "Hello, world!"
}
```

Returns previous value, new value, and post-change element state.

### observe_changes

Watch for UI changes in an application.

**Parameters:**
- `app` (required): Application name or PID
- `events` (optional): Event types to watch (`value_changed`, `focus_changed`, `window_created`, `window_destroyed`, `title_changed`). Omit for all.
- `duration` (optional): Seconds to observe (default: 30, max: 300)

**Example request:**
```json
{ "app": "TextEdit", "events": ["value_changed"], "duration": 10 }
```

Events are batched and returned when the duration ends. Max 1000 events per observation.

## Troubleshooting

### "permission_denied" error

Accessibility permissions aren't granted.

1. Open **System Settings** > **Privacy & Security** > **Accessibility**
2. Add the application running the server (Claude Desktop or your terminal)
3. Restart the application after granting permissions

### "app_not_running" error

The app name doesn't match any running application. Use the exact name as shown in the Dock or Activity Monitor. You can also use a numeric PID.

### "timeout" error

The UI tree is too large. Reduce the `depth` parameter (try 1 or 2) or use `find_element` with specific criteria instead.

### "element_path_error" or "invalid_element" error

The UI changed since you got the element path. Re-run `get_ui_tree` or `find_element` to get fresh paths.

### "blocklisted_application" error

Write operations are blocked for this app. Read operations still work. See the Safety Features section to customize the blocklist.

### "read_only_mode" error

Remove the `--read-only` flag or unset `ACCESSIBILITY_MCP_READ_ONLY`.

### Claude Desktop can't connect to the server

- Check the binary path in `claude_desktop_config.json` is correct and absolute
- Make sure the binary has execute permissions: `chmod +x /path/to/accessibility-mcp`
- Restart Claude Desktop after editing the config
- Check Console.app for logs under subsystem `com.adamrdrew.accessibility-mcp`

## Limitations

- Observation events are batched (returned at end of duration, not streamed)
- Write operations cannot be undone
- Maximum 1000 events per observation, 300s max duration
- No interactive confirmation dialogs (MCP protocol limitation)

## Development

Run the test suite:

```bash
swift test
```

This project uses [Ushabti](https://github.com/adamrdrew/ushabti) for iterative development. See `.ushabti/` for phase plans and progress.

## License

MIT
