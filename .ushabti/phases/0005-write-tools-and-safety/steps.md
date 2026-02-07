# Implementation Steps

## S001: ServerConfiguration and Read-Only Mode

**Intent**: Establish the configuration infrastructure that gates all write operations before any write code exists.

**Work**:
- Create ServerConfiguration struct in Security/ directory with properties: readOnlyMode (Bool), rateLimitPerSecond (Int), blockedBundleIDs ([String])
- Parse `--read-only` CLI flag from CommandLine.arguments in main.swift
- Parse `ACCESSIBILITY_MCP_READ_ONLY=1` environment variable
- Parse `ACCESSIBILITY_MCP_RATE_LIMIT` environment variable (default: 10)
- Parse `ACCESSIBILITY_MCP_BLOCKLIST` environment variable (comma-separated bundle IDs, merged with defaults)
- Pass ServerConfiguration into AccessibilityServer so it can control tool list and call dispatch
- Write tests for configuration parsing: CLI flag, env var, defaults, combined precedence

**Done when**:
- ServerConfiguration parses from CLI args and env vars
- Read-only mode detectable from both flag and env var
- Tests verify all parsing paths and default values

## S002: ApplicationBlocklist

**Intent**: Prevent write operations on security-sensitive applications.

**Work**:
- Create ApplicationBlocklist actor in Security/ directory
- Define default blocklist bundle IDs: com.apple.keychainaccess, com.apple.Terminal, com.googlecode.iterm2, com.apple.systempreferences
- Accept additional bundle IDs from ServerConfiguration
- Implement `isBlocked(bundleID: String) -> Bool` method
- Implement `isBlocked(appName: String, resolver: any AppResolver, bridge: any AXBridge) -> Bool` that resolves app name to bundle ID for checking
- Create BlocklistError with case blockedApplication(appName: String, bundleID: String) including guidance
- Write tests for: default blocklist, custom additions, non-blocked apps pass, blocked apps rejected

**Done when**:
- ApplicationBlocklist actor enforces default and configurable blocklist
- Bundle ID lookup works for app name inputs
- Tests verify blocking and pass-through behavior

## S003: RateLimiter

**Intent**: Prevent runaway automation loops by throttling write operations.

**Work**:
- Create RateLimiter actor in Security/ directory
- Track action timestamps in a sliding window
- Implement `checkAndRecord() async` method that:
  - Prunes timestamps older than 1 second
  - If current count >= limit, calculates required delay and sleeps
  - Records current timestamp
  - Returns a RateLimitResult indicating whether delay was applied
- Create RateLimitResult struct with: allowed (Bool), delayApplied (TimeInterval?)
- Configurable max actions per second from ServerConfiguration
- Write tests for: within limit (no delay), at limit (delay applied), timestamps pruned correctly

**Done when**:
- RateLimiter actor tracks and enforces per-second rate limit
- Delay-based throttling works (sleep when burst detected)
- Tests verify rate limiting behavior

## S004: Write Tool Parameter and Response Structs

**Intent**: Define parameter and response types for perform_action and set_value following the Phase 4 pattern.

**Work**:
- Create PerformActionParameters struct (Codable): app (String), elementPath (String), action (String)
  - Add validate() method: all fields required, action must be recognized
- Create SetValueParameters struct (Codable): app (String), elementPath (String), value (AnyCodableValue)
  - AnyCodableValue: enum wrapping String, Bool, Int, Double for JSON value decoding
  - Add validate() method: all fields required
- Create ActionResponse struct (Codable): success (Bool), action (String), elementState (ElementStateInfo), rateLimitWarning (String?)
- Create SetValueResponse struct (Codable): success (Bool), previousValue (String?), newValue (String?), elementState (ElementStateInfo), rateLimitWarning (String?)
- Create ElementStateInfo struct (Codable): role, title, value, enabled, focused, actions, path — reusable post-action state snapshot
- Write tests for: parameter parsing from JSON, validation, response serialization

**Done when**:
- All parameter and response structs defined, Codable, tested
- AnyCodableValue handles string, boolean, and number JSON values
- Validation catches missing and invalid parameters

## S005: Post-Action State Reader

**Intent**: Extract a reusable component that reads element state after an action for verification.

**Work**:
- Create ElementStateReader struct in Actions/ directory
- Implement `readState(element: UIElement, path: String, bridge: any AXBridge) throws(AccessibilityError) -> ElementStateInfo`
- Read: role, title, value, enabled, focused, available actions
- Handle gracefully if element becomes invalid after action (return partial state with note)
- Write tests with MockAXBridge: successful state read, partial state on error

**Done when**:
- ElementStateReader produces ElementStateInfo from a live element
- Graceful degradation when element becomes invalid post-action
- Tests verify full and partial state reads

## S006: PerformActionHandler

**Intent**: Implement the perform_action tool handler with full safety checks.

**Work**:
- Create PerformActionHandler struct in Tools/ directory
- Inject dependencies: AppResolver, AXBridge, ElementResolver, ElementStateReader, ApplicationBlocklist, RateLimiter, ServerConfiguration
- Execute flow:
  1. Check read-only mode → error if enabled
  2. Resolve app to PID
  3. Check blocklist → error if blocked
  4. Rate limiter check (may delay)
  5. Parse element_path string into ElementPath
  6. Resolve element_path to live UIElement
  7. Validate element supports requested action (getActionNames)
  8. Perform action via AXBridge.performAction
  9. Read post-action state via ElementStateReader
  10. Return ActionResponse with state and optional rate limit warning
- Handle all error cases with ErrorConverter pattern
- Write tests for: success path, read-only blocked, blocklist blocked, rate limited, invalid path, action not supported, element not found

**Done when**:
- PerformActionHandler executes actions with all safety gates
- Post-action state returned in response
- All error paths tested with structured error responses

## S007: SetValueHandler

**Intent**: Implement the set_value tool handler with value type coercion and safety checks.

**Work**:
- Create SetValueHandler struct in Tools/ directory
- Inject same dependencies as PerformActionHandler
- Execute flow:
  1. Check read-only mode → error if enabled
  2. Resolve app to PID
  3. Check blocklist → error if blocked
  4. Rate limiter check (may delay)
  5. Parse element_path and resolve to live UIElement
  6. Read current value for "previousValue" in response
  7. Coerce incoming value to appropriate AX type based on AnyCodableValue case
  8. Set value via AXBridge.setAttribute(.value, ...)
  9. Read post-change state via ElementStateReader
  10. Return SetValueResponse with previous value, new value, and element state
- Write tests for: string values, boolean values, number values, read-only blocked, blocklist blocked, rate limited, invalid path

**Done when**:
- SetValueHandler sets values with type coercion and all safety gates
- Response includes previous and new values plus element state
- All value types and error paths tested

## S008: Wire Write Tools to MCP Server

**Intent**: Register perform_action and set_value with the MCP server, integrating safety checks into the dispatch path.

**Work**:
- Add perform_action and set_value tool schemas to AccessibilityServer.tools() — conditionally included based on read-only mode
- Add cases in callTool() for "perform_action" and "set_value" that decode parameters, instantiate handlers with dependencies, execute, and return JSON responses
- Update AccessibilityServer to accept ServerConfiguration
- Instantiate ApplicationBlocklist and RateLimiter from ServerConfiguration
- Pass safety dependencies to write tool handlers
- Update main.swift to parse CLI args and env vars into ServerConfiguration before creating server
- Write tests for: tool list includes/excludes write tools based on read-only mode, tool dispatch routes correctly

**Done when**:
- Write tools appear in tool list when read-only is off
- Write tools hidden from tool list when read-only is on
- Tool invocations route to correct handlers with safety dependencies
- Server startup respects configuration from CLI and env

## S009: ErrorConverter Updates for Write Operations

**Intent**: Extend ErrorConverter to handle new error types from write operations.

**Work**:
- Add convertElementPathError(ElementPathError, operation: String, app: String) method
- Add convertBlocklistError(BlocklistError, operation: String) method
- Add convertReadOnlyError(operation: String) method for read-only mode rejections
- Add convertActionError for action-specific failures (action not supported, element invalid post-action)
- Ensure all new error conversions include: operation, errorType, message, app, elementPath, guidance
- Write tests for all new error conversion paths

**Done when**:
- ErrorConverter handles all write-operation error types
- All error responses include required context fields
- Tests verify error conversion for each new error type

## S010: Integration Tests for Write Tools

**Intent**: Verify end-to-end write tool behavior with mocked dependencies.

**Work**:
- Write integration tests that instantiate write handlers with MockAXBridge, MockAppResolver, and real safety actors
- Test perform_action full flow: resolve app → resolve path → validate action → perform → return state
- Test set_value full flow: resolve app → resolve path → read current → coerce → set → return state
- Test safety integration: read-only mode blocks writes but not reads, blocklist blocks specific apps, rate limiter delays bursts
- Test error propagation: invalid app, invalid path, permission denied, action not supported, invalid value type
- Verify all responses conform to expected JSON schemas
- Verify post-action state is present in all success responses

**Done when**:
- Integration tests cover both write tools with success and error paths
- Safety feature integration tested end-to-end
- All tests pass with MockAXBridge

## S011: Update README with Write Tool Documentation

**Intent**: Document write tools, safety features, and configuration for users.

**Work**:
- Add perform_action section: purpose, parameters, return value structure, example usage, supported actions
- Add set_value section: purpose, parameters, value types (string/boolean/number), return value, examples
- Add Safety Features section:
  - Read-only mode: how to enable, what it blocks, when to use
  - Application blocklist: defaults, how to customize, what it restricts
  - Rate limiting: default limit, how to configure, behavior when exceeded
- Add configuration reference: all environment variables and CLI flags
- Add examples showing the agency loop: find element → perform action → verify state

**Done when**:
- README documents both write tools with parameters and examples
- Safety features documented with configuration instructions
- Configuration reference is complete and accurate
