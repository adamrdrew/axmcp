# Implementation Steps

## Step 1: Add getWindows to AXBridge protocol

**Intent**: Define the protocol method for retrieving windows using the safe CFArray conversion pattern.

**Work**:
- Add `getWindows(from element: UIElement) throws(AccessibilityError) -> [UIElement]` method signature to `AXBridge` protocol in `/Users/adam/Development/macos-accessibility-mcp/Sources/AccessibilityMCP/AXBridge/AXBridge.swift`

**Done when**:
- `AXBridge` protocol includes `getWindows` method signature
- Compiler shows errors for missing implementation in conforming types

## Step 2: Implement getWindows in LiveAXBridge

**Intent**: Provide the concrete implementation using the CFArray conversion pattern that already works for children.

**Work**:
- Create `/Users/adam/Development/macos-accessibility-mcp/Sources/AccessibilityMCP/AXBridge/LiveAXBridge+WindowsOperations.swift`
- Implement `getWindows` method that fetches `.windows` attribute as `CFArray` and calls `convertToUIElements`
- Follow the same pattern as `copyChildren` in `LiveAXBridge+ChildrenOperations.swift`

**Done when**:
- `LiveAXBridge` compiles without errors
- `getWindows` implementation mirrors the `copyChildren` pattern
- Method uses `getAttributeValue` to fetch CFArray, then `convertToUIElements`

## Step 3: Update ElementResolver window resolution methods

**Intent**: Fix the type mismatch bug in window array fetching.

**Work**:
- Update `resolveWindowByIndex` in `ElementResolver+Resolution.swift` to call `bridge.getWindows(from: element)` instead of `bridge.getAttribute(.windows, from: element)`
- Update `resolveWindowByTitle` in `ElementResolver+Resolution.swift` to call `bridge.getWindows(from: element)` instead of `bridge.getAttribute(.windows, from: element)`
- Remove the `do-catch` blocks as the typed throws will propagate correctly

**Done when**:
- Both methods use `bridge.getWindows(from:)`
- Type annotations for `windows: [UIElement]` are removed (inferred from return type)
- Error propagation uses typed throws without manual conversion

## Step 4: Update ListWindowsHandler window fetching

**Intent**: Fix the type mismatch bug in list_windows tool.

**Work**:
- Update `getAppWindows` method in `ListWindowsHandler.swift` to call `bridge.getWindows(from: appElement)` instead of `bridge.getAttribute(.windows, from: appElement)`
- Remove the `try?` and `?? []` fallback — let errors propagate as typed throws

**Done when**:
- `getAppWindows` uses `bridge.getWindows(from:)`
- Errors propagate via typed throws instead of being silenced with `try?`
- Method signature includes appropriate `throws` clause

## Step 5: Update ElementFinder element resolution

**Intent**: Remove silent failure in find_element path resolution.

**Work**:
- Update `resolveElement(from:bridge:)` in `ElementFinder+Matching.swift` to handle errors explicitly instead of returning `nil` via `try?`
- Consider whether to propagate errors or log them — review existing error handling patterns in the ElementFinder

**Done when**:
- `resolveElement` does not use `try?` to silence errors
- Error handling is explicit and follows project patterns
- Failed resolutions produce diagnostic context

## Step 6: Add PID parameter to TreeTraverser

**Intent**: Thread application PID context through tree traversal to enable query-format path building.

**Work**:
- Add `applicationPID: pid_t` parameter to `traverse` method in `TreeTraverser.swift`
- Thread the parameter through to `buildNode` and `buildChildren` helper methods
- Update `buildPath` signature in `TreeTraverser+PathBuilding.swift` to accept `applicationPID`

**Done when**:
- `traverse` method signature includes `applicationPID` parameter
- Parameter is threaded through all internal helper methods
- `buildPath` receives PID context

## Step 7: Update TreeTraverser path building to query format

**Intent**: Emit query-format paths that are parseable and usable by write tools.

**Work**:
- Update `buildPath` method in `TreeTraverser+PathBuilding.swift` to construct query-format paths
- Root node should emit `app(PID)`
- Windows should emit `window[index]` (track window index during traversal)
- Children should emit `RoleName[index]` (track index per role during traversal)
- May need to add index tracking to `buildChildren` and `buildNode`

**Done when**:
- Paths are in format `app(12345)/window[0]/AXButton[1]` instead of `AXApplication/AXWindow/AXButton`
- Paths include application PID in root component
- Paths include indices for windows and children
- Index tracking correctly handles multiple children with the same role

## Step 8: Update GetUITreeHandler to pass PID

**Intent**: Provide PID context to the traverser.

**Work**:
- Update `GetUITreeHandler.swift` to extract application PID from the resolved element or application context
- Pass the PID to `traverser.traverse(element:options:bridge:applicationPID:)`
- Handle cases where PID is not available (system-wide elements)

**Done when**:
- `GetUITreeHandler` calls `traverse` with `applicationPID` parameter
- PID is correctly extracted from application resolution context
- Edge cases (system-wide elements) are handled appropriately

## Step 9: Test window resolution with applications

**Intent**: Verify that window arrays resolve correctly and tools work end-to-end.

**Work**:
- Run `list_windows` tool against a test application with multiple windows
- Run `find_element` tool with window-based paths
- Run `set_value` or `perform_action` tools with window-based paths
- Verify no type mismatch errors occur
- Verify windows are returned correctly

**Done when**:
- `list_windows` returns window arrays for test applications
- Window-based element paths resolve without errors in write tools
- No `as?` casting failures or type mismatch errors in logs

## Step 10: Test path format compatibility end-to-end

**Intent**: Verify that `get_ui_tree` paths work with write tools.

**Work**:
- Run `get_ui_tree` for a test application
- Copy a path from the output (e.g., `app(12345)/window[0]/AXButton[1]`)
- Use that path with `set_value` or `perform_action` tool
- Verify the path parses correctly and resolves to the expected element
- Verify ElementPath parsing handles the new format

**Done when**:
- Paths from `get_ui_tree` output parse successfully via `ElementPath(parsing:)`
- Paths resolve to correct elements when used with write tools
- No parsing errors or resolution failures
- Integration test covers the full round-trip: tree → path → resolve

## Step 11: Verify existing tests pass

**Intent**: Ensure no regressions were introduced.

**Work**:
- Run full test suite: `swift test`
- Fix any broken tests related to path format changes
- Update test expectations if path format changed (e.g., assertions on path strings)

**Done when**:
- All existing tests pass
- Any tests with hardcoded path format expectations are updated
- No new test failures introduced by these changes

## Follow-up Step F1: Add dedicated test for getWindows method

**Intent**: Satisfy L23 (public method test coverage) by adding explicit tests for the new getWindows method.

**Work**:
- Create test file: `Tests/AccessibilityMCPTests/AXBridge/AXBridgeWindowsTests.swift`
- Add test that verifies `getWindows` returns window arrays correctly
- Add test that verifies type safety of CFArray conversion
- Add test that verifies error handling when windows attribute is not available
- Ensure MockAXBridge properly simulates window array behavior

**Done when**:
- Test file exists with at least 3 test cases covering getWindows
- Tests explicitly verify the CFArray to [UIElement] conversion that was the core bug fix
- Tests pass with full coverage

## Follow-up Step F2: Refactor TreeTraverser+PathBuilding to comply with Sandi Metz method line limits

**Intent**: Fix style violation where multiple methods exceed 5-line limit.

**Work**:
- Extract helper functions from methods exceeding 5 lines in TreeTraverser+PathBuilding.swift
- Break buildChildren (~34 lines) into smaller focused methods
- Break createNodeWithPath (~28 lines) into composition of smaller methods
- Break buildChildrenWithPath (~30 lines) into smaller methods
- Break other violating methods (buildChildPath, buildNodeWithPath, getRoleInternal, getNodeChildrenWithPath, buildPath) into helper functions
- Maintain existing behavior and test compatibility

**Done when**:
- All methods in TreeTraverser+PathBuilding.swift are ≤5 lines of code (excluding signature and closing brace)
- Existing tests still pass (257 tests)
- Code remains readable and maintains clear intent

## Follow-up Step F3: Split TreeTraverser+PathBuilding to comply with type size limits

**Intent**: Fix style violation where the file/extension exceeds 100-line limit (currently 209 lines).

**Work**:
- Identify logical groupings in the 209-line file
- Consider splitting into separate extensions:
  - TreeTraverser+PathBuilding.swift (path construction logic)
  - TreeTraverser+NodeBuilding.swift (node creation logic)
  - TreeTraverser+ChildrenTraversal.swift (children traversal logic)
- Or extract separate types for distinct responsibilities
- Ensure each resulting file/type is ≤100 non-blank, non-comment lines
- Maintain test compatibility

**Done when**:
- No single type or extension exceeds 100 lines
- Code organization is logical and clear
- All existing tests pass
- File organization follows project structure conventions
