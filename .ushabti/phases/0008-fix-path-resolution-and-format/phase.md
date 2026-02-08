# Phase 8: Fix Path Resolution and Format

## Intent

Fix the ObjC/Swift bridging bug that breaks element resolution and unify path formats so `get_ui_tree` output can be used directly by write tools.

Multiple tools fail because window arrays are fetched through the generic `getAttribute<T>` path with `T` inferred as `[UIElement]`. The AX API returns `__NSArrayM` containing raw `AXUIElement` objects that can't bridge to `[UIElement]` via `as?`. The working pattern already exists in `getChildren(from:)` which fetches as `CFArray` then converts via `convertToUIElements`. This blocks `set_value`, `perform_action`, `find_element`, and `list_windows`.

Additionally, `get_ui_tree` emits display paths like `AXApplication/AXWindow/AXToolbar` while write tools expect query paths like `app(PID)/window[0]/AXToolbar[0]`. Users cannot copy a path from tree output and use it with write tools.

## Scope

**In scope:**
- Add `getWindows` helper method to `AXBridge` protocol and `LiveAXBridge` implementation using the CFArray conversion pattern
- Update `ElementResolver+Resolution.swift` (`resolveWindowByIndex`, `resolveWindowByTitle`) to use the new helper
- Update `ListWindowsHandler.swift` (`getAppWindows`) to use the new helper
- Update `ElementFinder+Matching.swift` (`resolveElement`) to handle errors explicitly instead of silent `try?` failures
- Add PID parameter threading through `TreeTraverser` to enable query-format path building
- Update `TreeTraverser+PathBuilding.swift` to emit query-format paths (e.g., `app(PID)/window[0]/AXButton[1]`)
- Update `GetUITreeHandler` to pass application PID to the traverser

**Out of scope:**
- Changes to `ElementPath` parsing logic (already supports query format)
- Modifications to action execution or value setting semantics
- Adding new MCP tools or changing tool signatures
- Performance optimizations beyond fixing the bug

## Constraints

**Relevant laws:**
- **L38**: Element attribute type safety — all attribute retrievals must be type-checked and safely coerced
- **L06**: Element reference validation — invalid references must produce structured errors, not crashes
- **L37**: Error context preservation — errors must include sufficient diagnostic context
- **L21**: Typed throws — all throwing functions use explicit error types
- **L23**: Public method test coverage — every public method must have at least one test

**Relevant style:**
- **Sandi Metz rules**: Methods ≤5 lines, types ≤100 lines, ≤4 parameters
- **Protocol-oriented design**: Use protocols for abstraction boundaries
- **Immutability**: Prefer `let` and value types
- **C API isolation**: All C API interactions in `AXBridge` module

## Acceptance Criteria

1. `set_value` tool resolves element paths without type mismatch errors
2. `perform_action` tool resolves element paths without type mismatch errors
3. `find_element` tool returns results and does not fail silently via `try?`
4. `list_windows` tool returns window arrays correctly for all applications
5. `get_ui_tree` emits paths in query format (e.g., `app(12345)/window[0]/AXButton[1]`)
6. Paths from `get_ui_tree` output are parseable by `ElementPath(parsing:)`
7. Paths from `get_ui_tree` output resolve correctly when used with write tools
8. All existing tests pass with no regressions
9. New tests verify window array resolution and path format compatibility

## Risks / Notes

**Known tradeoffs:**
- The traverser will need PID context, which requires threading the parameter through the call chain. This is acceptable because the traverser already requires scoped context (it operates on a specific application's tree).

**Intentionally deferred:**
- Performance optimization of path building (can be addressed in future phases if needed)
- Support for window-by-title in query paths (currently only index is used; title support can be added later if needed)
