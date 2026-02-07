# Steps for Phase 0002

## S001: Define Swift Wrapper Types

**Intent**: Establish the Swift types that represent AX concepts in a type-safe, Swift-native way. These types form the vocabulary for all code above the bridge layer.

**Work**:
- Create AccessibilityError enum mapping AXError codes (success, failure, invalidUIElement, cannotComplete, attributeUnsupported, actionUnsupported, notificationUnsupported, notImplemented, notificationAlreadyRegistered, notificationNotRegistered, apiDisabled, noValue, parameterizedAttributeUnsupported, notEnoughPrecision)
- Add permission-specific error cases (permissionDenied with guidance message)
- Add type safety error cases (typeMismatch, attributeNotFound)
- Create ElementAttribute enum for common attributes (role, title, description, value, children, parent, enabled, focused, position, size, identifier, roleDescription, subrole, windows, focusedWindow, mainWindow, custom)
- Create ElementRole enum for common roles (application, window, button, textField, staticText, checkBox, menu, menuItem, group, toolbar, list, table, cell, custom)
- Create ElementAction enum for actions (press, pick, showMenu, confirm, cancel, raise, increment, decrement, custom)

**Done when**:
- All enums defined in separate files in Sources/AccessibilityMCP/AXBridge/Types/
- Each enum has a custom case for extensibility
- AccessibilityError conforms to Error and has descriptive associated values
- All files compile with Swift 6 strict concurrency

---

## S002: Define UIElement Wrapper

**Intent**: Wrap AXUIElement (a C CFType) in a Swift type that is Sendable, memory-safe, and hides the C type from the rest of the codebase.

**Work**:
- Create UIElement struct in Sources/AccessibilityMCP/AXBridge/Types/UIElement.swift
- Store the underlying AXUIElement using Unmanaged or another memory-safe approach
- Implement Sendable conformance (required for Swift 6 concurrency)
- Implement proper CFType retain/release lifecycle (or use Swift's automatic handling via CF bridging)
- Add initializer taking AXUIElement
- Add computed property or method to access the underlying AXUIElement for bridge layer use
- Ensure no force-unwrapping

**Done when**:
- UIElement type defined with AXUIElement wrapped safely
- Sendable conformance implemented
- Memory management is correct (no leaks, no use-after-free)
- File compiles with Swift 6 strict concurrency

---

## S003: Define AXBridge Protocol

**Intent**: Create the abstraction boundary between C-level AX APIs and Swift code. This protocol defines all operations the rest of the codebase can perform, enabling testability through MockAXBridge.

**Work**:
- Create AXBridge protocol in Sources/AccessibilityMCP/AXBridge/AXBridge.swift
- Define methods:
  - createApplicationElement(pid: pid_t) throws(AccessibilityError) -> UIElement
  - createSystemWideElement() throws(AccessibilityError) -> UIElement
  - getAttribute<T>(_ attribute: ElementAttribute, from element: UIElement) throws(AccessibilityError) -> T
  - setAttribute(_ attribute: ElementAttribute, value: Any, on element: UIElement) throws(AccessibilityError)
  - getAttributeNames(from element: UIElement) throws(AccessibilityError) -> [ElementAttribute]
  - getActionNames(from element: UIElement) throws(AccessibilityError) -> [ElementAction]
  - performAction(_ action: ElementAction, on element: UIElement) throws(AccessibilityError)
  - getChildren(from element: UIElement) throws(AccessibilityError) -> [UIElement]
- Use typed throws with AccessibilityError (enforced by L21)
- Keep protocol focused on core operations only

**Done when**:
- AXBridge protocol defined with all required methods
- All methods use typed throws
- Protocol compiles with Swift 6 strict concurrency

---

## S004: Implement Permission Detection

**Intent**: Detect whether the process has Accessibility permissions and provide actionable error messages when permissions are missing (enforced by L07).

**Work**:
- Create PermissionChecker struct in Sources/AccessibilityMCP/AXBridge/PermissionChecker.swift
- Implement checkAccessibilityPermissions() throws(AccessibilityError) method
- Call AXIsProcessTrusted() to check permission status
- Throw AccessibilityError.permissionDenied with guidance message if permissions are missing
- Guidance message: "Grant Accessibility permissions in System Settings > Privacy & Security > Accessibility"
- Keep method simple (≤5 lines per Sandi Metz rules)

**Done when**:
- PermissionChecker type defined with checkAccessibilityPermissions() method
- Method calls AXIsProcessTrusted() and throws descriptive error on failure
- File compiles with Swift 6 strict concurrency

---

## S005: Implement LiveAXBridge

**Intent**: Implement the real AXBridge that calls actual ApplicationServices AX APIs. This is the production implementation.

**Work**:
- Create LiveAXBridge struct in Sources/AccessibilityMCP/AXBridge/LiveAXBridge.swift
- Conform to AXBridge protocol
- Implement createApplicationElement using AXUIElementCreateApplication(pid)
- Implement createSystemWideElement using AXUIElementCreateSystemWide()
- Implement getAttribute using AXUIElementCopyAttributeValue with type checking and safe coercion (enforced by L38)
- Implement setAttribute using AXUIElementSetAttributeValue
- Implement getAttributeNames using AXUIElementCopyAttributeNames, mapping CFStrings to ElementAttribute
- Implement getActionNames using AXUIElementCopyActionNames, mapping CFStrings to ElementAction
- Implement performAction using AXUIElementPerformAction
- Implement getChildren by reading AXChildren attribute and mapping to [UIElement]
- Map AXError codes to AccessibilityError cases
- Handle type mismatches gracefully (return AccessibilityError.typeMismatch, never crash)
- Keep each method ≤5 lines (extract helper methods as needed)

**Done when**:
- LiveAXBridge type defined conforming to AXBridge
- All protocol methods implemented
- Type checking and safe coercion implemented for getAttribute
- AXError codes mapped to AccessibilityError
- File compiles with Swift 6 strict concurrency
- No force-unwrapping in any method

---

## S006: Implement MockAXBridge

**Intent**: Implement a mock AXBridge for testing. This enables all tests to run without requiring real AX API access or specific system UI state (enforced by L27).

**Work**:
- Create MockAXBridge struct in Tests/AccessibilityMCPTests/Mocks/MockAXBridge.swift
- Conform to AXBridge protocol
- Store mock data: dictionary of UIElement -> attributes, actions, children
- Implement all AXBridge methods by returning mock data
- Allow tests to configure mock responses (set attributes, children, available actions)
- Support simulating errors (permission denied, element not found, type mismatch)
- Keep implementation simple and focused on test support

**Done when**:
- MockAXBridge type defined in test target conforming to AXBridge
- All protocol methods implemented returning configurable mock data
- Can simulate errors for testing error paths
- File compiles with Swift 6 strict concurrency

---

## S007: Test Permission Detection

**Intent**: Verify permission detection logic works correctly (enforced by L23).

**Work**:
- Create PermissionCheckerTests.swift in Tests/AccessibilityMCPTests/
- Test that checkAccessibilityPermissions() throws AccessibilityError.permissionDenied when AXIsProcessTrusted() returns false (simulate via test helper if possible, or document manual verification)
- Verify error message includes actionable guidance
- Use Swift Testing framework (@Test attributes, #expect)

**Done when**:
- Test file created with permission detection tests
- Tests pass
- Swift Testing framework used

---

## S008: Test LiveAXBridge Attribute Reading

**Intent**: Verify LiveAXBridge can read element attributes with type safety (enforced by L23, L38).

**Work**:
- Create LiveAXBridgeTests.swift in Tests/AccessibilityMCPTests/
- Test getAttribute with valid attribute returns expected type
- Test getAttribute with type mismatch throws AccessibilityError.typeMismatch
- Test getAttribute with missing attribute throws AccessibilityError.attributeNotFound
- Test getAttributeNames returns array of ElementAttribute
- Use MockAXBridge or controlled test element if real AX access is unavailable in test environment
- Use Swift Testing framework

**Done when**:
- Test file created with attribute reading tests
- All error paths tested
- Tests pass using MockAXBridge or controlled elements

---

## S009: Test LiveAXBridge Element Creation

**Intent**: Verify LiveAXBridge can create application and system-wide elements (enforced by L23).

**Work**:
- Add tests to LiveAXBridgeTests.swift
- Test createApplicationElement with valid PID returns UIElement
- Test createApplicationElement with invalid PID throws AccessibilityError
- Test createSystemWideElement returns UIElement
- Use Swift Testing framework

**Done when**:
- Tests added for element creation
- Tests pass

---

## S010: Test LiveAXBridge Children Enumeration

**Intent**: Verify LiveAXBridge can enumerate child elements (enforced by L23).

**Work**:
- Add tests to LiveAXBridgeTests.swift
- Test getChildren returns array of UIElement
- Test getChildren with element that has no children returns empty array
- Use MockAXBridge or controlled test element
- Use Swift Testing framework

**Done when**:
- Tests added for children enumeration
- Tests pass

---

## S011: Test MockAXBridge

**Intent**: Verify MockAXBridge works correctly for test scenarios (enforced by L23).

**Work**:
- Create MockAXBridgeTests.swift in Tests/AccessibilityMCPTests/
- Test that MockAXBridge can return configured mock attributes
- Test that MockAXBridge can return configured mock children
- Test that MockAXBridge can return configured mock actions
- Test that MockAXBridge can simulate errors
- Use Swift Testing framework

**Done when**:
- Test file created with MockAXBridge tests
- All mock capabilities verified
- Tests pass

---

## S012: Verify Swift 6 Compliance and Build

**Intent**: Ensure the entire phase compiles cleanly under Swift 6 strict concurrency with zero warnings.

**Work**:
- Run `swift build` and verify zero warnings
- Run `swift test` and verify all tests pass
- Verify no force-unwrapping exists in production code (grep for `!` operator)
- Verify Sendable conformance is correct for UIElement
- Verify no C types (AXUIElement, CFString, CFArray) leak above AXBridge/ module

**Done when**:
- `swift build` succeeds with zero warnings
- `swift test` succeeds with all tests passing
- No force-unwrapping in production code
- All acceptance criteria from phase.md verified

---

## F001: Refactor LiveAXBridge for Sandi Metz Compliance

**Intent**: Bring LiveAXBridge.swift into compliance with Sandi Metz rules (≤100 lines per type, ≤5 lines per method).

**Work**:
- Extract helper methods to reduce all methods to ≤5 lines
- If file still exceeds 100 lines after extraction, split LiveAXBridge into multiple types:
  - Potential split: LiveAXBridge (main struct conforming to AXBridge protocol), separate private helper types for attribute operations, action operations, children operations, type conversion
  - Alternative: Extract all private helper methods into extension(s) in separate file(s) (if this satisfies the 100-line rule)
- Maintain all existing functionality and test coverage
- Verify `swift build` still succeeds with zero warnings
- Verify all tests still pass

**Done when**:
- LiveAXBridge.swift (or split types) complies with Sandi Metz rules: all types ≤100 lines, all methods ≤5 lines
- All existing tests pass
- No new warnings introduced
