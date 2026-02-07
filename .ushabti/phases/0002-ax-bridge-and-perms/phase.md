# Phase 0002: AX Bridge & Permission Detection

## Intent

Build the foundational Accessibility API bridge layer that wraps C-level macOS Accessibility APIs in Swift types. This phase creates the abstraction boundary between the C-level ApplicationServices framework and the Swift-native code that will power all future phases. By isolating C type interactions in a protocol-based bridge layer, we enable testability, type safety, and memory safety throughout the codebase.

This phase also implements Accessibility permission detection, ensuring the server can verify permissions before attempting AX operations and provide actionable error messages when permissions are missing.

The bridge layer is the engine. No MCP tools are wired yet — this phase proves the engine works in isolation.

## Scope

This phase MUST:
1. Define the AXBridge protocol abstracting all core C-level AX operations (create elements, read attributes, list children, list attribute names, list action names, perform actions, set values)
2. Implement LiveAXBridge that calls real ApplicationServices AX APIs
3. Implement MockAXBridge for testing without real AX API access
4. Define Swift wrapper types:
   - UIElement — wraps AXUIElement with Sendable conformance and memory-safe CFType handling
   - AccessibilityError — typed error enum mapping AXError codes to Swift errors
   - ElementAttribute — enum for common AX attribute names (AXRole, AXTitle, AXValue, AXChildren, AXParent, AXEnabled, AXFocused, AXPosition, AXSize, AXIdentifier)
   - ElementRole — enum for common AX roles (AXButton, AXTextField, AXWindow, AXMenu, AXCheckBox, AXStaticText, AXGroup, AXApplication, etc.)
   - ElementAction — enum for AX actions (AXPress, AXPick, AXShowMenu, AXConfirm, AXCancel, AXRaise, AXIncrement, AXDecrement)
5. Implement permission detection using AXIsProcessTrusted() with clear, actionable error messages
6. Implement basic element attribute reading through the bridge with type-safe coercion (enforced by L38)
7. Implement element children enumeration through the bridge
8. Handle CFType memory management correctly (AXUIElement is a CFType requiring proper lifecycle management)
9. Write comprehensive tests for all public methods using MockAXBridge (enforced by L23, L27)

This phase MUST NOT:
- Wire any MCP tools (that's Phase 3)
- Implement tree traversal logic (separate concern for a future phase)
- Implement element path resolution (separate concern)
- Implement the tool-level logic for actions or value setting (bridge provides the capability, but tool logic comes later)

## Constraints

### Laws
- **L01**: Swift 6 language mode with strict concurrency enabled
- **L02**: No private APIs — only public, documented macOS Accessibility APIs
- **L07**: Accessibility permission detection with structured error and actionable guidance
- **L21**: All throwing functions must use typed throws
- **L22**: Use Swift Testing framework (not XCTest)
- **L23**: Every public method must have at least one test
- **L27**: Unit tests must use mocked AX API, not real system UI elements
- **L38**: Element attribute type checking and safe coercion — type mismatches return errors, never crash
- **L20**: Actor-based state management for any mutable state

### Style
- Protocol-oriented programming for the AXBridge abstraction (critical for testability)
- C API interactions isolated to AXBridge/ module — no C types leak above this layer
- Sandi Metz rules: ≤100 lines per type, ≤5 lines per method, ≤4 parameters
- Prefer immutability (let over var, value types over reference types)
- No force-unwrapping in production code
- Descriptive error types with context (enforced by L37)

## Acceptance Criteria

- AXBridge protocol defined with methods for all core AX operations (create application element, create system-wide element, get attribute, set attribute, get attribute names, get action names, perform action, get children)
- LiveAXBridge compiles and calls real ApplicationServices AX APIs
- MockAXBridge enables full testing without real AX API access
- Permission detection works correctly using AXIsProcessTrusted() and returns structured AccessibilityError with guidance when permissions are missing
- Swift wrapper types are fully defined:
  - UIElement wraps AXUIElement with Sendable conformance and CFType memory management
  - AccessibilityError maps all relevant AXError codes
  - ElementAttribute enum covers all common attributes
  - ElementRole enum covers all common roles
  - ElementAction enum covers all common actions
- Element attribute reading works through the bridge with type-safe coercion (no crashes on type mismatches)
- Element children enumeration works through the bridge
- All public methods have tests using MockAXBridge (enforced by L23)
- Tests pass with Swift Testing framework
- No C types (AXUIElement, CFString, CFArray, AXError) appear in any public API above the AXBridge/ module
- `swift build` succeeds with zero warnings under Swift 6 strict concurrency
- No force-unwrapping in production code

## Risks / Notes

- **Memory management complexity**: AXUIElement is a CFType. Must use proper retain/release semantics or Swift's Unmanaged type. UIElement wrapper must handle this safely.
- **Type coercion fragility**: AX API returns CFTypeRef (untyped). Attribute access must type-check and handle mismatches gracefully (enforced by L38).
- **Permission checking timing**: AXIsProcessTrusted() should be called early (at server startup or first AX access). This phase implements the check, but integration with server lifecycle happens in a future phase.
- **Sendable conformance**: UIElement must be Sendable for Swift 6 concurrency. Since AXUIElement is a CFType (reference), this requires careful design (likely wrapping the raw pointer value or using Unmanaged).
- **Incomplete enum coverage**: Not every AX attribute/role/action will be in the enums initially. Provide a `.custom(String)` case for extensibility.
- **No tool integration yet**: This phase proves the bridge works. Tool wiring happens in Phase 3 after tree traversal is implemented.
