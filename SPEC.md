# AxMCP — Product Specification

## Document Status
- **Version:** 1.0
- **Date:** February 7, 2026
- **Status:** Ready for Ushabti Development
- **Sibling Project:** [Spotlight MCP Server](https://github.com/adamrdrew/spotlight-mcp) (v0.1.0, released)

---

## 1. Vision

AxMCP is a macOS MCP server written in Swift that exposes the macOS Accessibility (AX) API to LLMs through the Model Context Protocol. It gives LLMs structured, semantic read and write access to any application's UI via the accessibility tree.

Unlike pixel-based screen-scraping agents (Anthropic Computer Use, OpenAI's equivalent), this server operates on a structured hierarchy of UI elements — buttons, text fields, menus, windows — with their types, roles, labels, states, and available actions. Unlike AppleScript, it works with **every** app, not just ones that opted into scripting dictionaries. Apple *requires* apps to support the Accessibility API, so coverage is near-universal across native macOS apps.

This turns an LLM into a universal macOS automation agent that can observe and drive any application.

### Differentiators

| Approach | Structured? | Universal? | Read+Write? |
|----------|-------------|------------|-------------|
| **AxMCP** | ✅ Semantic tree | ✅ All apps | ✅ Full |
| AppleScript MCP | ✅ Dictionaries | ❌ Opt-in only | ✅ Full |
| Computer Use agents | ❌ Pixels | ✅ All apps | ✅ Full |
| macOS Shortcuts | ✅ Actions | ❌ Predefined only | ✅ Limited |
| Hammerspoon | ✅ AX APIs | ✅ All apps | ✅ Full (no LLM) |

### The Agency Loop

The killer feature is the feedback loop. The AX tree tells the LLM the state *after* it acts. So the LLM can press a button, read the new UI state, decide what to do next, and keep going. This is not scripted automation — it is *agency*.

Example: "File my expenses. Here are the receipts." The LLM opens the company's expense app — which has no API, no AppleScript dictionary — and drives it like a human would, reading the structured accessibility tree instead of squinting at pixels.

---

## 2. Tech Stack

| Component | Choice | Rationale |
|-----------|--------|-----------|
| Language | Swift 6 | Memory safety, typed throws, strict concurrency |
| Build system | Swift Package Manager | Standard Swift tooling |
| Transport | stdio | Standard MCP transport for Claude Desktop |
| SDK | [Swift MCP SDK](https://github.com/modelcontextprotocol/swift-sdk) | First-party MCP implementation |
| Framework | ApplicationServices | macOS AX API (C-level, callable from Swift) |
| Testing | Swift Testing | Modern first-party framework |
| Development | Ushabti | Phased agent-driven development |
| Distribution | Homebrew (tap) | Same as Spotlight MCP |

---

## 3. Core Platform APIs

The server uses the macOS Accessibility API from the ApplicationServices framework. These are C-level APIs callable from Swift.

### Element Management
- `AXUIElementCreateApplication(pid)` — Get root element for any running app by process ID
- `AXUIElementCreateSystemWide()` — Get the system-wide accessibility element
- `AXUIElement` — The fundamental type representing any UI element

### Reading
- `AXUIElementCopyAttributeValue` — Read a single attribute (role, title, value, children, position, size, enabled state)
- `AXUIElementCopyAttributeNames` — List all attributes on an element
- `AXUIElementCopyActionNames` — List available actions

### Writing
- `AXUIElementPerformAction` — Execute actions (AXPress, AXPick, AXShowMenu, AXConfirm, AXCancel)
- `AXUIElementSetAttributeValue` — Set values (text content, checkbox state, slider position)

### Observation
- `AXObserver` — Subscribe to UI change notifications (value changed, focus moved, window created/destroyed)

### Key AX Attributes

| Attribute | Description | Example Values |
|-----------|-------------|----------------|
| AXRole | Element type | AXButton, AXTextField, AXWindow, AXMenu, AXCheckBox |
| AXTitle | Human-readable label | "Save", "File", "Document 1" |
| AXDescription | Accessible description | "Save the current document" |
| AXValue | Current value | Text content, checkbox state, slider position |
| AXChildren | Child elements | Array of AXUIElements |
| AXParent | Parent element | Single AXUIElement |
| AXEnabled | Interactive state | true/false |
| AXFocused | Focus state | true/false |
| AXPosition | Screen coordinates | {x: 100, y: 200} |
| AXSize | Dimensions | {w: 300, h: 50} |
| AXIdentifier | Developer-assigned ID | "saveButton" (when present) |
| AXRoleDescription | Localized description | "button", "text field" |

---

## 4. MCP Tools

### 4.1 get_ui_tree (Read)

Returns the accessibility tree for a given application.

**Parameters:**
- `app` (required) — Application name or PID
- `depth` (optional, default: 3) — Maximum traversal depth
- `include_attributes` (optional) — Which attributes to include (role, title, value, enabled, identifier, actions)
- `filter_roles` (optional) — Only include elements matching these roles

**Returns:** JSON hierarchy of elements with role, title, value, enabled state, available actions, and child count at each level.

**Design Notes:**
- Default depth of 3 prevents overwhelming the LLM context window
- Must support expanding specific subtrees on demand (follow-up call with element path + deeper depth)
- For complex apps (Xcode, browsers), a full tree can be enormous — depth limiting is essential

### 4.2 find_element (Read)

Search for UI elements matching criteria within a target app.

**Parameters:**
- `app` (required) — Application name or PID
- `role` (optional) — AX role to match (AXButton, AXTextField, etc.)
- `title` (optional) — Title text to match (supports substring/contains)
- `value` (optional) — Value to match
- `identifier` (optional) — Developer-assigned identifier
- `max_results` (optional, default: 20) — Result limit

**Returns:** Array of matching elements with their paths in the tree (for use as references in subsequent calls).

**Design Notes:**
- This is "Spotlight for UI elements" — find the button named "Save" without traversing the whole tree
- Returns element paths that can be used with perform_action and set_value
- Case-insensitive matching by default (lesson learned from Spotlight MCP)

### 4.3 perform_action (Write)

Execute an action on a specific UI element.

**Parameters:**
- `app` (required) — Application name or PID
- `element_path` (required) — Path to the target element (from get_ui_tree or find_element)
- `action` (required) — Action name (AXPress, AXPick, AXShowMenu, AXConfirm, AXCancel, AXRaise, AXIncrement, AXDecrement)

**Returns:** The UI state of the target element and its immediate context *after* the action, so the LLM can verify the outcome.

**Design Notes:**
- This is where real side effects happen — pressing buttons, selecting menus, confirming dialogs
- Post-action state return is critical for the agency loop
- Must validate the element still exists before acting (UI may have changed between calls)

### 4.4 set_value (Write)

Set the value of a UI element.

**Parameters:**
- `app` (required) — Application name or PID
- `element_path` (required) — Path to the target element
- `value` (required) — New value (string for text fields, boolean for checkboxes, number for sliders)

**Returns:** The element state after the value change.

**Design Notes:**
- Distinct from perform_action because setting data is conceptually different from triggering behavior
- Must handle type coercion (string to the appropriate AX value type)

### 4.5 get_focused_element (Read)

Get the currently focused/active element across the system or within a specific app.

**Parameters:**
- `app` (optional) — Specific app, or system-wide if omitted

**Returns:** The focused element with its full attribute set and path.

**Design Notes:**
- Quick orientation tool — "what am I looking at right now?"
- Useful as a starting point before more targeted operations

### 4.6 list_windows (Read)

Get all windows for an app or across all apps.

**Parameters:**
- `app` (optional) — Specific app, or all apps if omitted
- `include_minimized` (optional, default: false) — Include minimized windows

**Returns:** Array of windows with titles, positions, sizes, frontmost status, minimized status, and owning application.

**Design Notes:**
- Orientation tool for the LLM to understand what's on screen
- Foundation for targeting specific windows in other operations

### 4.7 observe_changes (Read, Subscription)

Subscribe to UI change notifications for an app. *(Phase 3)*

**Parameters:**
- `app` (required) — Application to observe
- `events` (optional) — Event types to watch (value_changed, focus_changed, window_created, window_destroyed, title_changed)
- `element_path` (optional) — Observe specific element only
- `duration` (optional, default: 30s) — How long to observe

**Returns:** Stream of change events with timestamps and affected elements.

**Design Notes:**
- Uses AXObserver under the hood
- May map to MCP resource subscriptions or a polling-based approach
- Server process must stay running to maintain subscriptions
- Integrate with Swift structured concurrency for callback management

---

## 5. Element Referencing Strategy

This is the hardest design problem. AXUIElements are ephemeral — they cannot be serialized or stored as stable references across tool calls.

### Chosen Approach: Path-Based, Re-Resolved

Element paths use a human-readable format that is re-resolved on each call:

```
app("Finder")/window[0]/toolbar/button["Save"]
app("Safari")/window["Google"]/group[0]/text_field["Address"]
```

**Path components:**
- `app("name")` or `app(pid)` — Application root
- `window[index]` or `window["title"]` — Window by index or title
- `role[index]` or `role["title"]` — Element by role with index or title disambiguation
- Chain with `/` to traverse deeper

**Resolution algorithm:**
1. Start from application root
2. Walk each path component, matching by role and title/index
3. If a component can't be resolved (UI changed), return a clear error explaining what was expected vs. what exists
4. Return the resolved AXUIElement for the operation

**Trade-offs:**
- Readable and understandable by both LLMs and humans
- Fragile if UI changes between calls (acceptable — the LLM can re-query)
- Re-resolution on each call is slower than caching but eliminates stale reference bugs

---

## 6. Security & Safety

### 6.1 Permissions

The server binary (or its parent process, e.g., Claude Desktop) must have Accessibility permissions granted in System Settings > Privacy & Security > Accessibility. The server must:

- Detect permission status on startup
- Provide a clear, actionable error message if permissions are missing
- Never attempt to bypass or escalate permissions
- Never prompt the user through UI automation to grant itself access

### 6.2 Read-Only Mode

The server must support a read-only mode that disables all write operations (perform_action, set_value). This allows safe exploration and observation without risk of unintended UI mutation.

**Configuration:** Environment variable or command-line flag (`--read-only`).

### 6.3 Application Scope

Some applications should be treated with extra caution:

**Default blocklist (configurable):**
- Keychain Access — credential management
- Terminal / iTerm2 — command execution
- System Settings — system configuration
- Security & Privacy panels

**Implementation:** Configurable allowlist/blocklist via configuration file. Blocklisted apps return a clear error explaining why access is restricted.

### 6.4 Action Safety

- All write operations must validate the target element exists and is in the expected state before acting
- Post-action state must be returned so the LLM can verify outcomes
- Rate limiting on write operations to prevent runaway automation (configurable, default: max 10 actions/second)

### 6.5 Privacy

- Do not log UI tree contents or element values in production
- Minimal logging at info level (tool invocation, app targeted, success/failure)
- Debug logging disabled in release builds

---

## 7. Architecture

### 7.1 Layer Diagram

```
┌─────────────────────────────────────┐
│           MCP Protocol Layer         │  stdio transport, tool dispatch
├─────────────────────────────────────┤
│          Tool Implementations        │  get_ui_tree, find_element, etc.
├─────────────────────────────────────┤
│         Accessibility Engine         │  Tree traversal, element search,
│                                     │  action execution, value setting
├─────────────────────────────────────┤
│         AX API Bridge Layer          │  Swift wrappers around C APIs,
│                                     │  type mapping, error translation
├─────────────────────────────────────┤
│      ApplicationServices (C API)     │  macOS Accessibility framework
└─────────────────────────────────────┘
```

### 7.2 Key Abstractions

- **AXBridge** — Protocol wrapping C-level AX APIs for testability (mock in tests, real implementation in production)
- **ElementPath** — Value type representing a path to an element in the tree
- **TreeNode** — Value type for serializable tree representation (role, title, value, children, actions)
- **ElementResolver** — Resolves an ElementPath to a live AXUIElement by walking the tree
- **TreeTraverser** — Depth-limited, filterable tree walking with JSON serialization
- **ActionExecutor** — Validates and performs actions, returns post-action state
- **PermissionChecker** — Detects Accessibility permission status

### 7.3 C API Bridging

The AX API is C-level. All C types must be wrapped in Swift types at the bridge layer:

- `AXUIElement` → `UIElement` (Swift wrapper with Sendable conformance)
- `AXError` → `AccessibilityError` (typed Swift error enum)
- `CFString` attribute names → Swift string constants or enum
- `CFArray` children → Swift arrays of `UIElement`
- Memory management: AXUIElements are CFTypes — use `Unmanaged` or `withExtendedLifetime` as appropriate

No C types should leak above the bridge layer into tool implementations.

---

## 8. Development Phases

### Phase 1: Skeleton — MCP Server with Stdio Transport
Bare MCP server that compiles, handshakes with Claude Desktop, and returns an empty tool list. Proves the Swift MCP SDK integration and stdio transport work.

### Phase 2: AX Bridge & Tree Traversal
Implement the AX API bridge layer and tree traversal. The server can read the accessibility tree for any running app with depth limiting and filtering. No MCP tools wired yet — just the engine.

### Phase 3: Read-Only Tools
Wire up `get_ui_tree`, `find_element`, `get_focused_element`, and `list_windows` as MCP tools. The server becomes usable for UI inspection.

### Phase 4: Write Tools
Add `perform_action` and `set_value`. Implement safety checks, rate limiting, read-only mode, and application blocklist.

### Phase 5: Observation
Add `observe_changes` using AXObserver. Integrate with Swift structured concurrency. Handle subscription lifecycle.

### Phase 6: Polish & Harden
Validation, error messages, logging, README, CHANGELOG, Homebrew formula, edge case handling.

---

## 9. Synergies

### Spotlight MCP + AxMCP
Find a file via Spotlight → open it → drive the application UI to do something with it. "Find the spreadsheet I was working on last week, open it in Numbers, select cell B2, and enter this value."

### AppleScript MCP + AxMCP
AppleScript for apps that support it (faster, more reliable scripting dictionary) → Accessibility as fallback for everything else. The two are complementary, not competing.

### Future MCP Servers
Calendar/Contacts + Accessibility: Look up a contact, open Mail, compose a message by driving the UI. The more MCP servers in the ecosystem, the more powerful the combinations.

---

## 10. Prior Art

| System | How It Works | Limitation |
|--------|-------------|------------|
| macOS Automator / Shortcuts | Predefined actions | No AI reasoning, limited to built-in actions |
| Hammerspoon | Lua scripting + AX APIs | No LLM connection, manual scripting only |
| Computer Use agents | Pixel-based screen reading | Fundamentally less reliable than structured tree access |
| Apple Voice Control | Uses AX APIs internally | Proves the approach works at system scale |
| macOS Switch Control | Uses AX APIs | Accessibility-focused, not automation-focused |

---

## 11. Success Criteria

1. **Can read the UI tree** of any running macOS application with depth limiting
2. **Can find specific elements** by role, title, value, or identifier
3. **Can perform actions** on elements (press buttons, select menus) and return post-action state
4. **Can set values** on elements (type text, toggle checkboxes)
5. **Works with Claude Desktop** as an MCP server over stdio
6. **Handles permissions gracefully** with clear error messages
7. **Supports read-only mode** for safe exploration
8. **Respects application blocklist** for sensitive apps
9. **All tests pass** with mocked AX API (no real UI dependency in tests)
10. **Single binary output** installable via Homebrew
