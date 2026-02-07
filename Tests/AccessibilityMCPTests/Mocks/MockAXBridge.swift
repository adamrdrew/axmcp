import Foundation
import ApplicationServices
@testable import AccessibilityMCP

struct MockAXBridge: AXBridge, @unchecked Sendable {
    var mockAttributes: [ElementAttribute: Any] = [:]
    var mockActions: [ElementAction] = []
    var mockChildren: [UIElement] = []
    var mockAttributeNames: [ElementAttribute] = []
    var shouldThrowPermissionDenied = false
    var shouldThrowInvalidElement = false
    var simulateSlowOperations = false
    var operationDelay: TimeInterval = 0.0

    func createApplicationElement(
        pid: pid_t
    ) throws(AccessibilityError) -> UIElement {
        try checkPermissions()
        return createMockElement()
    }

    func createSystemWideElement(
    ) throws(AccessibilityError) -> UIElement {
        try checkPermissions()
        return createMockElement()
    }

    func getAttribute<T>(
        _ attribute: ElementAttribute,
        from element: UIElement
    ) throws(AccessibilityError) -> T {
        simulateDelay()
        try checkPermissions()
        try checkElement()
        guard let value = mockAttributes[attribute] else {
            throw AccessibilityError.attributeNotFound(
                attribute.rawValue
            )
        }
        guard let typedValue = value as? T else {
            throw AccessibilityError.typeMismatch(
                expected: "\(T.self)",
                actual: "\(type(of: value))"
            )
        }
        return typedValue
    }

    func setAttribute(
        _ attribute: ElementAttribute,
        value: Any,
        on element: UIElement
    ) throws(AccessibilityError) {
        try checkPermissions()
        try checkElement()
    }

    func getAttributeNames(
        from element: UIElement
    ) throws(AccessibilityError) -> [ElementAttribute] {
        try checkPermissions()
        try checkElement()
        return mockAttributeNames.isEmpty
            ? Array(mockAttributes.keys)
            : mockAttributeNames
    }

    func getActionNames(
        from element: UIElement
    ) throws(AccessibilityError) -> [ElementAction] {
        try checkPermissions()
        try checkElement()
        return mockActions
    }

    func performAction(
        _ action: ElementAction,
        on element: UIElement
    ) throws(AccessibilityError) {
        try checkPermissions()
        try checkElement()
        guard mockActions.contains(action) else {
            throw AccessibilityError.actionUnsupported
        }
    }

    func getChildren(
        from element: UIElement
    ) throws(AccessibilityError) -> [UIElement] {
        simulateDelay()
        try checkPermissions()
        try checkElement()
        return mockChildren
    }

    private func checkPermissions(
    ) throws(AccessibilityError) {
        guard !shouldThrowPermissionDenied else {
            throw AccessibilityError.permissionDenied(
                guidance: "Mock permission denied"
            )
        }
    }

    private func checkElement(
    ) throws(AccessibilityError) {
        guard !shouldThrowInvalidElement else {
            throw AccessibilityError.invalidUIElement
        }
    }

    func createMockElement() -> UIElement {
        UIElement(AXUIElementCreateSystemWide())
    }

    private func simulateDelay() {
        guard simulateSlowOperations && operationDelay > 0 else {
            return
        }
        Thread.sleep(forTimeInterval: operationDelay)
    }
}

