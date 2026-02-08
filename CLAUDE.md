# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AxMCP is a macOS MCP server (Swift 6, Swift Package Manager) that exposes the macOS Accessibility API to LLMs via the Model Context Protocol over stdio. It gives LLMs structured read/write access to any application's UI through the accessibility tree. Full specification in SPEC.md.

We use Ushabti, an iterative agile agentic development framework. Overview: https://raw.githubusercontent.com/adamrdrew/ushabti/refs/heads/master/README.md

## Build & Test Commands

```bash
swift build                    # Debug build
swift build -c release         # Release build (binary at .build/release/axmcp)
swift test                     # Run all tests
swift test --filter AxMCPTests.TreeTraverserTests  # Run a specific test class
```

## Architecture

### Layer Stack

```
main.swift → AccessibilityServer → ToolDispatcher → Tool Handlers → AXBridge → macOS AX API
```

- **main.swift** — Entry point. Creates `ServerConfiguration` (from env vars), `ServerContext` (actor), `Server` (MCP SDK), registers handlers, starts stdio transport.
- **AccessibilityServer** — Static factory. Wires up `ToolDispatcher` with `LiveAXBridge` and `LiveAppResolver`, registers MCP `ListTools`/`CallTool` handlers on the `Server`.
- **ServerContext** (actor) — Holds runtime state: `ServerConfiguration`, `ApplicationBlocklist`, `RateLimiter`, `ObserverManager`.
- **ToolRegistry** — Declares MCP tool schemas. Split into `+ReadTools`, `+WriteTools`, `+ObserveTools` extensions. Write tools are excluded in read-only mode.
- **ToolDispatcher** — Routes `CallTool` requests by name. Split into `+ReadTools` (get_ui_tree, find_element, get_focused_element, list_windows), `+WriteTools` (perform_action, set_value), `+ObserveTools` (observe_changes).

### Source Directory Layout

- **AXBridge/** — `AXBridge` protocol (the testability seam) and `LiveAXBridge` (real macOS AX API calls via ApplicationServices). Types subdirectory has `UIElement`, `AccessibilityError`, `ElementAttribute`, `ElementAction`, `ElementRole`. Also contains `PermissionChecker`.
- **ElementReference/** — `ElementPath` (value type for path-based element references like `app("Finder")/window[0]/button[@title='Save']`), `ElementResolver` (walks the AX tree to resolve a path to a live `AXUIElement`), `ElementFinder` (search by criteria), `SearchCriteria`.
- **TreeTraversal/** — `TreeTraverser` (depth-limited, filterable tree walking), `TreeNode` (serializable tree representation), `TreeTraversalOptions`.
- **Tools/** — Individual tool handler structs (e.g., `GetUITreeHandler`, `FindElementHandler`, `PerformActionHandler`), parameter/response types, `AppResolver` protocol + `LiveAppResolver`, `ErrorConverter` (translates internal errors to user-friendly MCP error responses).
- **Actions/** — Write operation types: `PerformActionParameters`, `SetValueParameters`, `ActionResponse`, `SetValueResponse`, `ElementStateReader`, `AnyCodableValue`.
- **Security/** — `ApplicationBlocklist`, `RateLimiter`, `ServerConfiguration`, `BlocklistError`.
- **Observers/** — `ObserverManager`, `EventCollector`, `ObserverBridge` protocol + `LiveObserverBridge`, `RunLoopThread`, event types.
- **Logging/** — `MCPLogger`, `LogCategory`, `LogDestination` protocol (production uses `OSLogDestination`).

### Key Design Patterns

- **Protocol-based testability**: `AXBridge`, `AppResolver`, and `ObserverBridge` are protocols. Production uses `Live*` implementations; tests use `Mock*` implementations in `Tests/AxMCPTests/Mocks/`.
- **Typed throws**: Swift 6 typed throws used throughout — e.g., `throws(AccessibilityError)`.
- **Strict concurrency**: `Sendable` conformance enforced everywhere. `ServerContext` is an actor. `StrictConcurrency` upcoming feature enabled in Package.swift.
- **No C types above bridge layer**: `AXUIElement` is wrapped in `UIElement`, `AXError` becomes `AccessibilityError`, CF types are converted to Swift types at the bridge boundary.
- **Element paths are re-resolved on every call**: Paths like `app("Finder")/window[0]/button[@title='Save']` are parsed and walked fresh each time since `AXUIElement` references are ephemeral.

### Testing

Tests use `MockAXBridge` (configure `mockAttributes`, `mockChildren`, `mockActions` dictionaries) and `MockAppResolver` (returns a configurable PID). No real UI interaction in tests. Uses Swift Testing framework (`@Test`, `#expect`).

