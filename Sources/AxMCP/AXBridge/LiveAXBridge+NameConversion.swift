import ApplicationServices

extension LiveAXBridge {
    func convertAttributeNames(
        _ names: CFArray?
    ) -> [ElementAttribute] {
        guard let names else { return [] }
        return mapAttributeNames(names)
    }

    func convertActionNames(
        _ names: CFArray?
    ) -> [ElementAction] {
        guard let names else { return [] }
        return mapActionNames(names)
    }

    func convertToUIElements(
        _ array: CFArray
    ) -> [UIElement] {
        let elements = array as NSArray
        return elements.compactMap(mapToUIElement)
    }
}

extension LiveAXBridge {
    private func mapAttributeNames(
        _ names: CFArray
    ) -> [ElementAttribute] {
        let array = names as [AnyObject]
        return array.compactMap(convertToAttribute)
    }

    private func convertToAttribute(
        _ name: AnyObject
    ) -> ElementAttribute? {
        guard let string = name as? String else { return nil }
        return ElementAttribute.from(string: string)
    }

    private func mapActionNames(
        _ names: CFArray
    ) -> [ElementAction] {
        let array = names as [AnyObject]
        return array.compactMap(convertToAction)
    }

    private func convertToAction(
        _ name: AnyObject
    ) -> ElementAction? {
        guard let string = name as? String else { return nil }
        return ElementAction.from(string: string)
    }

    private func mapToUIElement(
        _ element: Any
    ) -> UIElement? {
        let cfElement = element as CFTypeRef
        guard validateElementType(cfElement) else { return nil }
        return createUIElement(from: cfElement)
    }

    private func validateElementType(
        _ element: CFTypeRef
    ) -> Bool {
        CFGetTypeID(element) == AXUIElementGetTypeID()
    }

    private func createUIElement(
        from cfElement: CFTypeRef
    ) -> UIElement {
        let axElement = unsafeDowncast(
            cfElement as AnyObject,
            to: AXUIElement.self
        )
        return UIElement(axElement)
    }
}
