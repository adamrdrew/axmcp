import ApplicationServices

extension LiveAXBridge {
    func copyWindows(
        from element: AXUIElement
    ) throws(AccessibilityError) -> [UIElement] {
        let windows = try getWindowsArray(from: element)
        return convertToUIElements(windows)
    }
}

extension LiveAXBridge {
    private func getWindowsArray(
        from element: AXUIElement
    ) throws(AccessibilityError) -> CFArray {
        try getAttributeValue(.windows, from: element)
    }
}
