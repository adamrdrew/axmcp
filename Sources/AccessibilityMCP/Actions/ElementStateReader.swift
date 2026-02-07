import Foundation

struct ElementStateReader: Sendable {
    func readState(
        element: UIElement,
        path: String,
        bridge: any AXBridge
    ) throws(AccessibilityError) -> ElementStateInfo {
        let role = readAttribute(
            .role,
            from: element,
            bridge: bridge
        )
        let title = readAttribute(
            .title,
            from: element,
            bridge: bridge
        )
        let value = readAttribute(
            .value,
            from: element,
            bridge: bridge
        )
        let enabled = readBoolAttribute(
            .enabled,
            from: element,
            bridge: bridge
        )
        let focused = readBoolAttribute(
            .focused,
            from: element,
            bridge: bridge
        )
        let actions = readActions(
            from: element,
            bridge: bridge
        )
        return ElementStateInfo(
            role: role,
            title: title,
            value: value,
            enabled: enabled,
            focused: focused,
            actions: actions,
            path: path
        )
    }

    private func readAttribute(
        _ attr: ElementAttribute,
        from element: UIElement,
        bridge: any AXBridge
    ) -> String? {
        try? bridge.getAttribute(attr, from: element)
    }

    private func readBoolAttribute(
        _ attr: ElementAttribute,
        from element: UIElement,
        bridge: any AXBridge
    ) -> Bool? {
        try? bridge.getAttribute(attr, from: element)
    }

    private func readActions(
        from element: UIElement,
        bridge: any AXBridge
    ) -> [String] {
        guard let actions = try? bridge.getActionNames(
            from: element
        ) else {
            return []
        }
        return actions.map { $0.rawValue }
    }
}
