# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-02-07

### Added

- MCP server with stdio transport and Swift 6 strict concurrency
- **Read-only tools:**
  - `get_ui_tree` — traverse accessibility tree with depth limiting, role filtering, and attribute filtering
  - `find_element` — search for elements by role, title, value, or identifier with result limits
  - `get_focused_element` — get the currently focused element (app-scoped or system-wide)
  - `list_windows` — list windows for an application or system-wide
- **Write tools:**
  - `perform_action` — execute accessibility actions (press, pick, show menu, confirm, cancel, raise, increment, decrement)
  - `set_value` — set element values with automatic type coercion (string, boolean, number)
- **Observation tool:**
  - `observe_changes` — watch for UI events (value changed, focus changed, window created/destroyed, title changed) with duration and event limits
- AX API bridge with protocol abstraction (`AXBridge`) and mock support for testing
- Path-based element referencing with parsing, serialization, and round-trip support
- Tree traversal engine with depth limiting, role/attribute filtering, and timeout enforcement
- Element search with multi-criteria matching and result limits
- **Safety features:**
  - Read-only mode (`--read-only` flag or `ACCESSIBILITY_MCP_READ_ONLY` env var)
  - Application blocklist with configurable bundle IDs (default: Keychain Access, Terminal, iTerm2, System Settings)
  - Rate limiting for write operations (default: 10 actions/second, configurable via `ACCESSIBILITY_MCP_RATE_LIMIT`)
  - Post-action state verification on all write operations
- Accessibility permission detection with actionable error guidance
- Observer subsystem with dedicated RunLoop thread, C callback bridging, and batch event collection
- Structured JSON error responses with operation context, error types, and actionable guidance
- Structured logging via os.log with subsystem `com.adamrdrew.accessibility-mcp`
- Actor-based state management for thread safety (ServerContext, ApplicationBlocklist, RateLimiter, ObserverManager)
- GitHub Actions workflows for CI testing and universal binary releases
- Homebrew tap formula for distribution
- 250+ tests using Swift Testing framework with full mock coverage
