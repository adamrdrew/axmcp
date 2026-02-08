import Foundation

protocol AXBridge: Sendable {
    func createApplicationElement(
        pid: pid_t
    ) throws(AccessibilityError) -> UIElement

    func createSystemWideElement(
    ) throws(AccessibilityError) -> UIElement

    func getAttribute<T>(
        _ attribute: ElementAttribute,
        from element: UIElement
    ) throws(AccessibilityError) -> T

    func setAttribute(
        _ attribute: ElementAttribute,
        value: Any,
        on element: UIElement
    ) throws(AccessibilityError)

    func getAttributeNames(
        from element: UIElement
    ) throws(AccessibilityError) -> [ElementAttribute]

    func getActionNames(
        from element: UIElement
    ) throws(AccessibilityError) -> [ElementAction]

    func performAction(
        _ action: ElementAction,
        on element: UIElement
    ) throws(AccessibilityError)

    func getChildren(
        from element: UIElement
    ) throws(AccessibilityError) -> [UIElement]

    func getWindows(
        from element: UIElement
    ) throws(AccessibilityError) -> [UIElement]
}
