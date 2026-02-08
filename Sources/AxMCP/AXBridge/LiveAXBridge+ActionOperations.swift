import ApplicationServices

extension LiveAXBridge {
    func copyActionNames(
        from element: AXUIElement
    ) throws(AccessibilityError) -> [ElementAction] {
        let names = try copyActionNamesArray(from: element)
        return convertActionNames(names)
    }

    func executeAction(
        _ action: ElementAction,
        on element: AXUIElement
    ) throws(AccessibilityError) {
        let error = performActionOnElement(action, on: element)
        try checkError(error)
    }
}

extension LiveAXBridge {
    private func copyActionNamesArray(
        from element: AXUIElement
    ) throws(AccessibilityError) -> CFArray? {
        var names: CFArray?
        let error = executeCopyActionNames(element, into: &names)
        try checkError(error)
        return names
    }

    private func executeCopyActionNames(
        _ element: AXUIElement,
        into names: inout CFArray?
    ) -> AXError {
        AXUIElementCopyActionNames(element, &names)
    }

    private func performActionOnElement(
        _ action: ElementAction,
        on element: AXUIElement
    ) -> AXError {
        AXUIElementPerformAction(
            element,
            action.rawValue as CFString
        )
    }
}
