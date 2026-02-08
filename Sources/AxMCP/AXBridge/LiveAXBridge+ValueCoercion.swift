import ApplicationServices

extension LiveAXBridge {
    func checkError(
        _ error: AXError
    ) throws(AccessibilityError) {
        guard error == .success else {
            throw AccessibilityError.from(code: error)
        }
    }

    func coerceValue<T>(
        _ value: CFTypeRef?,
        attribute: ElementAttribute
    ) throws(AccessibilityError) -> T {
        let unwrapped = try unwrapValue(value, attribute: attribute)
        return try castValue(unwrapped, attribute: attribute)
    }
}

extension LiveAXBridge {
    private func unwrapValue(
        _ value: CFTypeRef?,
        attribute: ElementAttribute
    ) throws(AccessibilityError) -> CFTypeRef {
        guard let value else {
            throw createAttributeNotFoundError(attribute)
        }
        return value
    }

    private func createAttributeNotFoundError(
        _ attribute: ElementAttribute
    ) -> AccessibilityError {
        AccessibilityError.attributeNotFound(
            attribute.rawValue
        )
    }

    private func castValue<T>(
        _ value: CFTypeRef,
        attribute: ElementAttribute
    ) throws(AccessibilityError) -> T {
        if let typedValue = value as? T {
            return typedValue
        }
        throw createTypeMismatchError(value: value, expectedType: T.self)
    }

    private func createTypeMismatchError(
        value: CFTypeRef,
        expectedType: Any.Type
    ) -> AccessibilityError {
        AccessibilityError.typeMismatch(
            expected: "\(expectedType)",
            actual: "\(type(of: value))"
        )
    }
}
