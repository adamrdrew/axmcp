# Phase 0007 — Steps

## S001: Add structured logging infrastructure

**Intent:** Establish os.log-based logging so all subsequent steps can use it.

**Work:**
- Create a `Logging/` directory under `Sources/AccessibilityMCP/`
- Define a `Logger` wrapper using `os.Logger` with subsystem `com.adamrdrew.accessibility-mcp`
- Define category constants: `server`, `tools`, `axbridge`, `security`, `observers`
- Add Info-level log at server startup (version, configuration summary — no sensitive data)
- Add Info-level log at each tool invocation (tool name, target app — no element data)
- Add Warning-level logs for rate limit hits, permission check failures
- Add Error-level logs for unrecoverable failures
- Add Debug-level logs for element resolution steps, tree traversal progress
- Verify: zero UI element content or tree data in Info/Warning/Error logs (L36)

**Done when:** `swift build` succeeds; server startup emits Info log visible in Console.app; no UI data in non-debug logs.

## S002: Write tests for logging behavior

**Intent:** Verify logging respects L36 (minimal result logging) and covers key events.

**Work:**
- Create a `MockLogger` or protocol-based logging abstraction that captures log messages for testing
- Write tests verifying: server start logs Info, tool invocation logs Info with tool name, rate limit hit logs Warning, errors log Error
- Write tests verifying: no element attributes, tree content, or UI values appear in Info/Warning/Error log messages
- Ensure logging abstraction is injectable (dependency injection, not global singleton)

**Done when:** Tests pass verifying log levels and L36 compliance.

## S003: Audit and improve error messages

**Intent:** Make every error message actionable for the user or LLM.

**Work:**
- Review `ErrorConverter.swift` and all error conversion extensions
- Review `AccessibilityError.swift`, `ElementPathError.swift`, `AppResolutionError.swift`, `ObserverError.swift`, `BlocklistError.swift`, `ToolParameterError.swift`, `ToolExecutionError.swift`
- For permission denied: ensure guidance includes "Open System Settings > Privacy & Security > Accessibility and enable this application"
- For app not found: query running applications and suggest similar names in the error guidance field
- For element path failures: include the path attempted and describe what was found vs. expected
- For blocklist rejections: name the blocked bundle ID and explain how to customize via `ACCESSIBILITY_MCP_ADDITIONAL_BLOCKLIST` or `ACCESSIBILITY_MCP_BLOCKLIST_OVERRIDE`
- For rate limit exceeded: include the current limit and `ACCESSIBILITY_MCP_RATE_LIMIT` env var name
- For stale/invalid element references: suggest re-running get_ui_tree or find_element
- For observer errors: include the app name and event types attempted

**Done when:** Every error path includes a `guidance` field with specific, actionable instructions. Manual review confirms all error types covered.

## S004: Write tests for improved error messages

**Intent:** Verify error messages contain actionable guidance.

**Work:**
- Add tests for each error type verifying the `guidance` field is non-nil and contains expected keywords
- Test permission denied includes "System Settings"
- Test app not found includes suggestion text
- Test blocklist error includes bundle ID and configuration env var name
- Test rate limit error includes current limit value
- Test element path error includes the attempted path string

**Done when:** Tests pass confirming all error guidance requirements.

## S005: Harden edge cases

**Intent:** Handle gracefully the scenarios where real-world usage diverges from the happy path.

**Work:**
- **App termination mid-operation:** Verify all tool handlers catch AX API errors from terminated apps and return structured errors (not crashes). Add specific test cases for MockAXBridge simulating `.invalidUIElement` / `.cannotComplete` errors mid-traversal.
- **Stale element paths:** When element path resolution fails because UI changed, include the path that was attempted and suggest re-traversal in the error.
- **Very large trees:** Verify `TreeTraverser` enforces `maxResults` (L13) and that trees exceeding 10,000 elements are truncated with a `truncated: true` flag and count. Add a test with a mock tree of >10,000 elements.
- **Non-standard AX implementations:** Verify `LiveAXBridge` attribute operations handle nil/unexpected attribute types without crashing (L38). Add test cases for elements missing standard attributes (no role, no title, no children attribute).
- **Observer edge cases:** Test observer behavior when target app terminates immediately after observer creation. Verify `ObserverManager` cleans up properly.

**Done when:** All edge case tests pass. No crashes or hangs on any edge case scenario.

## S006: Complete CHANGELOG.md for v0.1.0

**Intent:** Document all shipped features per L30.

**Work:**
- Update CHANGELOG.md with comprehensive v0.1.0 entry covering:
  - **Added:** All 7 MCP tools (get_ui_tree, find_element, get_focused_element, list_windows, perform_action, set_value, observe_changes)
  - **Added:** AX API bridge with protocol abstraction and mock support
  - **Added:** Path-based element referencing with parsing and resolution
  - **Added:** Tree traversal with depth limiting, role/attribute filtering, timeout enforcement
  - **Added:** Safety features: read-only mode, application blocklist, rate limiting
  - **Added:** Observer subsystem with duration and event limits
  - **Added:** Structured JSON error responses with actionable guidance
  - **Added:** Structured logging via os.log
  - **Added:** Claude Desktop integration support
  - **Added:** Homebrew tap distribution
  - **Added:** 227+ tests using Swift Testing framework
- Follow Keep a Changelog format

**Done when:** CHANGELOG.md has complete v0.1.0 entry reflecting all features.

## S007: Polish README.md

**Intent:** Ensure README meets L31 completeness requirements.

**Work:**
- Review current README (523 lines) against L31 checklist:
  - [ ] Installation via Homebrew (`brew tap adamrdrew/accessibility-mcp && brew install accessibility-mcp`)
  - [ ] Building from source instructions
  - [ ] Claude Desktop configuration JSON snippet (exact JSON for `claude_desktop_config.json`)
  - [ ] Accessibility permission setup (step-by-step with System Settings path)
  - [ ] All 7 tools documented with parameters, return schemas, and usage examples
  - [ ] Safety features: read-only mode, blocklist, rate limiting (with configuration reference)
  - [ ] Environment variable reference table
  - [ ] Troubleshooting section (common errors and fixes)
  - [ ] Limitations / known issues
- Add any missing sections
- Verify all example JSON snippets are valid and match actual tool schemas
- Ensure Homebrew installation instructions are present (even if formula not yet published)

**Done when:** README passes L31 checklist. All sections present and accurate.

## S008: Create GitHub Actions release workflow

**Intent:** Automate universal binary builds on release tag push.

**Work:**
- Create `.github/workflows/release.yml`:
  - Trigger: push tag matching `v*`
  - Build on macOS runner (macos-14 or later for arm64 support)
  - Build release binary: `swift build -c release --arch arm64 --arch x86_64`
  - Verify single binary with `lipo -info` and `otool -L`
  - Create GitHub Release with the binary attached
  - Generate SHA256 checksum and attach to release
- Create `.github/workflows/test.yml`:
  - Trigger: push to main, pull requests
  - Run `swift test` on macOS runner
  - Verify `swift build -c release` succeeds

**Done when:** Workflow files exist and are structurally valid YAML. Full CI testing requires a push to GitHub.

## S009: Create Homebrew tap formula

**Intent:** Enable `brew install` distribution.

**Work:**
- Create formula file suitable for a Homebrew tap repository (document the expected tap repo structure)
- Formula should:
  - Download universal binary from GitHub release
  - Verify SHA256 checksum
  - Install to bin
  - Include `test` block that runs `accessibility-mcp --help` or version check
- Document the tap repository setup in README (repo name: `homebrew-accessibility-mcp`)
- Include instructions for updating formula on new releases (SHA256 + URL update)

**Done when:** Formula file is valid Ruby. Tap setup documented in README.

## S010: Run full test suite and verify

**Intent:** Confirm all tests pass after all changes.

**Work:**
- Run `swift test` — all tests must pass
- Run `swift build -c release` — release build must succeed
- Verify no compiler warnings
- Verify binary is single executable: check with `otool -L`
- Count total tests and confirm count matches expectations (should be > 227 with new tests added)

**Done when:** `swift test` exits 0. `swift build -c release` exits 0. No warnings. Test count documented.

## S011: Document Claude Desktop integration verification

**Intent:** Confirm end-to-end functionality with Claude Desktop.

**Work:**
- Document the manual verification procedure:
  1. Build release binary
  2. Configure Claude Desktop with the server (JSON config snippet)
  3. Start conversation and invoke a read tool (e.g., `get_ui_tree` on Finder)
  4. Invoke a write tool (e.g., `perform_action` to press a button)
  5. Invoke observe_changes
  6. Verify structured responses returned correctly
- Record results in phase review (pass/fail for each step)
- This step is manual verification, not automated

**Done when:** Verification procedure documented. Results recorded (even if some steps cannot be tested without Claude Desktop present).

## S012: Refactor ErrorConverter.swift to meet 100-line limit

**Intent:** Split ErrorConverter into focused, single-responsibility types to comply with Sandi Metz Rule #1.

**Work:**
- Create AppErrorConverter for app resolution errors
- Create AccessibilityErrorConverter for AX API errors
- Create TraversalErrorConverter for tree traversal errors
- Update ErrorConverter to be a facade delegating to specialized converters
- Verify all call sites still compile
- Ensure no behavioral changes

**Done when:** ErrorConverter.swift ≤100 logical lines (excluding blanks/comments), all tests pass.

## S013: Refactor ErrorConverter+WriteOperations.swift to meet 100-line limit

**Intent:** Reduce extension size by extracting message formatting to comply with Sandi Metz Rule #1.

**Work:**
- Create ElementPathErrorMessages struct with static methods for message/guidance formatting
- Create BlocklistErrorMessages struct with static method for guidance formatting
- Update extension to call these types instead of private methods
- Verify all call sites still compile
- Ensure no behavioral changes

**Done when:** ErrorConverter+WriteOperations.swift ≤100 logical lines (excluding blanks/comments), all tests pass.

## S014: Verify Sandi Metz compliance after refactoring

**Intent:** Confirm all files meet 100-line limit and no regressions introduced.

**Work:**
- Count logical lines (excluding blanks/comments) in all modified files using grep -v '^\s*$' | grep -v '^\s*//' | wc -l
- Run full test suite: swift test
- Verify no regressions

**Done when:** All files ≤100 lines, 256+ tests pass.

## S015: Refactor AccessibilityServer.swift to meet Sandi Metz rules

**Intent:** Split AccessibilityServer into focused types meeting 100-line and 5-line limits to comply with Sandi Metz Rules #1, #2, and #4.

**Work:**
- Create ToolRegistry struct to manage tool definitions (readTools, writeTools, observeTools)
- Create ToolDispatcher struct to route tool calls and handle execution
- Inject AppResolver and AXBridge dependencies into ToolDispatcher initializer (fixes Rule #4 violation)
- Update AccessibilityServer to delegate to ToolRegistry and ToolDispatcher
- Break down `callTool`, `readTools`, `writeTools` into ≤5 line methods
- Update main.swift and registerHandlers to use new structure
- Verify all call sites compile
- Ensure no behavioral changes

**Done when:** AccessibilityServer.swift ≤100 logical lines, all methods ≤5 lines, all tests pass.

## S016: Verify L36 compliance in error descriptions

**Intent:** Ensure error logging does not leak UI data, verifying compliance with L36 (Minimal Result Logging).

**Work:**
- Audit all error types for description property content
- Verify no error descriptions include element attributes, UI content, or tree data
- If violations found, sanitize error descriptions or create logging-safe summaries
- Add test verifying error descriptions don't contain UI data keywords (AXButton, role, title, children, etc.)
- Focus on errors logged in AccessibilityServer.swift line 226

**Done when:** All error types verified L36 compliant, test coverage added, no UI data in error logs.

## S017: Final Sandi Metz and L36 verification

**Intent:** Confirm all refactoring meets requirements and no regressions introduced.

**Work:**
- Count logical lines (excluding blanks/comments) in AccessibilityServer.swift, ErrorConverter.swift, ErrorConverter+WriteOperations.swift
- Verify all files ≤100 lines
- Verify all methods ≤5 lines
- Run full test suite: swift test
- Verify 256+ tests pass
- Check for compiler warnings

**Done when:** All Sandi Metz rules satisfied, all tests pass, no warnings, L36 verified.
