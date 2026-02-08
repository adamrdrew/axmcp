import ApplicationServices

struct LiveAXBridge: AXBridge {
    func createApplicationElement(
        pid: pid_t
    ) throws(AccessibilityError) -> UIElement {
        UIElement(AXUIElementCreateApplication(pid))
    }

    func createSystemWideElement(
    ) throws(AccessibilityError) -> UIElement {
        UIElement(AXUIElementCreateSystemWide())
    }

    func getAttribute<T>(
        _ attribute: ElementAttribute,
        from element: UIElement
    ) throws(AccessibilityError) -> T {
        try getAttributeValue(attribute, from: element.rawElement)
    }

    func setAttribute(
        _ attribute: ElementAttribute,
        value: Any,
        on element: UIElement
    ) throws(AccessibilityError) {
        try setAttributeValue(
            attribute,
            value: value,
            on: element.rawElement
        )
    }

    func getAttributeNames(
        from element: UIElement
    ) throws(AccessibilityError) -> [ElementAttribute] {
        try copyAttributeNames(from: element.rawElement)
    }

    func getActionNames(
        from element: UIElement
    ) throws(AccessibilityError) -> [ElementAction] {
        try copyActionNames(from: element.rawElement)
    }

    func performAction(
        _ action: ElementAction,
        on element: UIElement
    ) throws(AccessibilityError) {
        try executeAction(action, on: element.rawElement)
    }

    func getChildren(
        from element: UIElement
    ) throws(AccessibilityError) -> [UIElement] {
        try copyChildren(from: element.rawElement)
    }

    func getWindows(
        from element: UIElement
    ) throws(AccessibilityError) -> [UIElement] {
        try copyWindows(from: element.rawElement)
    }
}
