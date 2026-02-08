import ApplicationServices

extension LiveAXBridge {
    func copyChildren(
        from element: AXUIElement
    ) throws(AccessibilityError) -> [UIElement] {
        let children = try getChildrenArray(from: element)
        return convertToUIElements(children)
    }
}

extension LiveAXBridge {
    private func getChildrenArray(
        from element: AXUIElement
    ) throws(AccessibilityError) -> CFArray {
        try getAttributeValue(.children, from: element)
    }
}
