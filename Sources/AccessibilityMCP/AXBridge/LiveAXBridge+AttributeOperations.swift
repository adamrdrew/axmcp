import ApplicationServices

extension LiveAXBridge {
    func getAttributeValue<T>(
        _ attribute: ElementAttribute,
        from element: AXUIElement
    ) throws(AccessibilityError) -> T {
        let value = try copyAttributeValue(attribute, from: element)
        return try coerceValue(value, attribute: attribute)
    }

    func setAttributeValue(
        _ attribute: ElementAttribute,
        value: Any,
        on element: AXUIElement
    ) throws(AccessibilityError) {
        let error = executeSetAttribute(attribute, value: value, on: element)
        try checkError(error)
    }

    func copyAttributeNames(
        from element: AXUIElement
    ) throws(AccessibilityError) -> [ElementAttribute] {
        let names = try copyAttributeNamesArray(from: element)
        return convertAttributeNames(names)
    }
}

extension LiveAXBridge {
    private func copyAttributeValue(
        _ attribute: ElementAttribute,
        from element: AXUIElement
    ) throws(AccessibilityError) -> CFTypeRef? {
        var value: CFTypeRef?
        try executeCopy(attribute, from: element, into: &value)
        return value
    }

    private func executeCopy(
        _ attribute: ElementAttribute,
        from element: AXUIElement,
        into value: inout CFTypeRef?
    ) throws(AccessibilityError) {
        let error = executeCopyAttributeValue(
            attribute,
            from: element,
            into: &value
        )
        try checkError(error)
    }

    private func executeCopyAttributeValue(
        _ attribute: ElementAttribute,
        from element: AXUIElement,
        into value: inout CFTypeRef?
    ) -> AXError {
        AXUIElementCopyAttributeValue(
            element,
            attribute.rawValue as CFString,
            &value
        )
    }

    private func executeSetAttribute(
        _ attribute: ElementAttribute,
        value: Any,
        on element: AXUIElement
    ) -> AXError {
        AXUIElementSetAttributeValue(
            element,
            attribute.rawValue as CFString,
            value as CFTypeRef
        )
    }

    private func copyAttributeNamesArray(
        from element: AXUIElement
    ) throws(AccessibilityError) -> CFArray? {
        var names: CFArray?
        let error = executeCopyAttributeNames(element, into: &names)
        try checkError(error)
        return names
    }

    private func executeCopyAttributeNames(
        _ element: AXUIElement,
        into names: inout CFArray?
    ) -> AXError {
        AXUIElementCopyAttributeNames(element, &names)
    }
}
