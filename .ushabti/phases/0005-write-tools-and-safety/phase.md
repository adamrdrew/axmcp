# Phase 0005: Write Tools & Safety

## Intent

Add write operations to the MCP server — `perform_action` and `set_value` — along with the safety infrastructure required to ship them responsibly: read-only mode, application blocklist, and rate limiting. After this phase, an LLM can press buttons, select menus, type text, toggle checkboxes, and adjust sliders, while the server enforces configurable guardrails to prevent misuse.

This phase transforms the server from a passive UI inspector into an active automation agent. Because actions have real side effects (closing windows, deleting content, executing commands), every write path must be gated by safety checks and must return post-action state so the LLM can verify outcomes.

## Scope

This phase MUST:
1. Define MCP tool schemas for two write tools:
   - `perform_action`: app (required), element_path (required), action (required — AXPress, AXPick, AXShowMenu, AXConfirm, AXCancel, AXRaise, AXIncrement, AXDecrement)
   - `set_value`: app (required), element_path (required), value (required — string, boolean, or number)
2. Implement PerformActionHandler:
   - Resolve app to PID via AppResolver
   - Parse and resolve element_path to live UIElement via ElementResolver
   - Validate the element supports the requested action via getActionNames
   - Perform the action via AXBridge.performAction
   - Read and return post-action element state (role, title, value, enabled, actions) and surrounding context
3. Implement SetValueHandler:
   - Resolve app to PID and element_path to live UIElement
   - Coerce the incoming JSON value to appropriate AX type (String, Bool/CFBoolean, Number)
   - Set value via AXBridge.setAttribute
   - Return post-change element state
4. Implement read-only mode:
   - Command-line flag: `--read-only`
   - Environment variable: `ACCESSIBILITY_MCP_READ_ONLY=1`
   - ServerConfiguration struct with readOnlyMode property
   - When enabled, perform_action and set_value return clear errors explaining restriction
   - Read-only tools (get_ui_tree, find_element, etc.) continue to work normally
   - Write tools are hidden from the tool list in read-only mode
5. Implement application blocklist:
   - Default blocklist: Keychain Access, Terminal, iTerm2, System Settings (by bundle identifier)
   - Configurable via environment variable: `ACCESSIBILITY_MCP_BLOCKLIST` (comma-separated bundle IDs)
   - ApplicationBlocklist actor with thread-safe checking
   - Blocklisted apps return clear error explaining restriction for write operations
   - Read operations continue to work on blocklisted apps (read-only access is safe)
6. Implement rate limiting:
   - RateLimiter actor with configurable max actions per second (default: 10)
   - Configurable via environment variable: `ACCESSIBILITY_MCP_RATE_LIMIT`
   - Applies to perform_action and set_value only
   - When exceeded, delay and warn rather than hard-fail
7. Wire write tools to MCP server with safety checks integrated into the call path
8. Write tests for:
   - Action execution (success, element not found, action not supported, path resolution failure)
   - Value setting (strings, booleans, numbers, type coercion)
   - Read-only mode blocking write operations while allowing reads
   - Blocklist enforcement (blocked app returns error, non-blocked app succeeds)
   - Rate limiting behavior (within limit succeeds, burst delayed)
   - Post-action state verification (response includes element state after action)
   - Write tool schema correctness
   - ServerConfiguration parsing from CLI args and env vars
9. Update README with write tool documentation, safety features, and configuration

This phase MUST NOT:
- Implement observation/subscription features (Phase 6)
- Modify read-only tools from Phase 4
- Implement a configuration file (environment variables and CLI flags are sufficient)
- Add confirmation dialogs or interactive prompts (the MCP protocol doesn't support them)

## Constraints

### Laws
- **L04**: Explicit application scope required — app parameter required for both write tools
- **L06**: Element reference validation — validate element paths before resolution; stale/invalid references return structured errors
- **L08**: Destructive action safeguards — read-only mode flag, write operations clearly documented as mutating
- **L09**: Application blocklist support — configurable blocklist with sensible defaults
- **L10**: Rate limiting enforcement — configurable rate limits on write operations
- **L11**: Action verification support — post-action state returned in all write responses
- **L12**: Structured JSON responses only — all responses return consistent JSON
- **L16**: Read/write operation separation — write tools clearly identifiable and separable from reads
- **L17**: Operation timeout enforcement — all operations enforce timeouts
- **L20**: Actor-based state management — RateLimiter and ApplicationBlocklist use actors
- **L21**: Typed throws for all error-throwing functions
- **L22**: Swift Testing framework for all tests
- **L23**: Every public method must have at least one test
- **L27**: Unit tests use MockAXBridge, not real AX API
- **L37**: Error context preservation — errors include operation, element path, app, and guidance

### Style
- Sandi Metz rules: <=100 lines per type, <=5 lines per method, <=4 parameters
- Handler pattern from Phase 4: Parameters struct + Handler + Response struct
- Dependency injection for all collaborators
- Protocol-oriented programming for testability
- Actor isolation for mutable state (rate limiter, blocklist)
- One type per file, files grouped by domain (Actions/, Security/, Tools/)

## Acceptance Criteria

- `perform_action` and `set_value` appear in MCP tool list when read-only mode is off
- `perform_action` and `set_value` are hidden from tool list when read-only mode is on
- `perform_action` resolves element path, validates action support, executes action, returns post-action state
- `set_value` resolves element path, coerces value type, sets attribute, returns post-change state
- Read-only mode:
  - Enabled by `--read-only` flag or `ACCESSIBILITY_MCP_READ_ONLY=1` env var
  - Write tools return structured error: "Write operations are disabled in read-only mode"
  - Read tools continue to work normally
- Application blocklist:
  - Default blocklist includes Keychain Access, Terminal, iTerm2, System Settings
  - Blocked apps return structured error: "Application 'X' is blocklisted for write operations"
  - Configurable via `ACCESSIBILITY_MCP_BLOCKLIST` env var
  - Read operations still work on blocklisted apps
- Rate limiting:
  - Default: 10 actions per second
  - Burst beyond limit is delayed (not rejected)
  - Configurable via `ACCESSIBILITY_MCP_RATE_LIMIT` env var
- All error responses include: operation, errorType, message, app, elementPath (where applicable), guidance
- All tests pass using MockAXBridge (no real AX API dependency)
- Swift build succeeds with zero warnings under Swift 6 strict concurrency
- README updated with write tool documentation, safety feature configuration, and examples

## Risks / Notes

- **Element staleness**: Between `find_element` and `perform_action`, the UI may change. Element path resolution on each call mitigates this, but the LLM should be aware that actions can fail if the UI changed. Clear error messages help.
- **Action side effects are irreversible**: Unlike reads, actions can't be undone. The blocklist and read-only mode provide safety nets, but users must understand the risks. README must document this.
- **Rate limiter delay vs. reject**: The spec calls for delay-and-warn rather than hard-fail. This means the rate limiter actor must track timestamps and sleep when burst is detected, then proceed. This is preferable to rejecting requests outright.
- **Value type coercion**: AX API expects specific types (CFBoolean for checkboxes, CFString for text fields, CFNumber for sliders). The handler must inspect the element's current value type and coerce accordingly. Document supported value types.
- **Blocklist granularity**: The blocklist applies to write operations only. Read operations on blocklisted apps are permitted because reading UI state is safe. This is a deliberate design choice.
- **No confirmation dialogs**: MCP protocol doesn't support interactive confirmation. Safety is enforced through configuration (blocklist, read-only mode) rather than runtime prompts.
