import Foundation

struct GetFocusedElementHandler: Sendable {
    private let resolver: any AppResolver
    private let bridge: any AXBridge

    init(resolver: any AppResolver, bridge: any AXBridge) {
        self.resolver = resolver
        self.bridge = bridge
    }

    func execute(
        parameters: GetFocusedElementParameters
    ) throws(ToolExecutionError) -> FocusedElementResponse {
        do {
            try parameters.validate()
            let focusedElement = try getFocusedElement(parameters)
            return createResponse(focusedElement)
        } catch let error as AppResolutionError {
            throw ErrorConverter.convertAppError(error, operation: "get_focused_element")
        } catch let error as AccessibilityError {
            throw ErrorConverter.convertAccessibilityError(error, operation: "get_focused_element", app: parameters.app)
        } catch {
            throw ToolExecutionError.toolError(
                ToolError(
                    operation: "get_focused_element",
                    errorType: "unknown_error",
                    message: "Unexpected error: \(error)",
                    app: parameters.app
                )
            )
        }
    }

    private func getFocusedElement(
        _ params: GetFocusedElementParameters
    ) throws -> UIElement? {
        if let appName = params.app {
            return try getAppFocusedElement(appName)
        }
        return try getSystemFocusedElement()
    }

    private func getAppFocusedElement(
        _ appName: String
    ) throws -> UIElement? {
        let pid = try resolver.resolve(appIdentifier: appName)
        let appElement = try bridge.createApplicationElement(pid: pid)
        return try? bridge.getAttribute(.focused, from: appElement)
    }

    private func getSystemFocusedElement(
    ) throws(AccessibilityError) -> UIElement? {
        let systemElement = try bridge.createSystemWideElement()
        return try? bridge.getAttribute(.focused, from: systemElement)
    }

    private func createResponse(
        _ element: UIElement?
    ) -> FocusedElementResponse {
        guard let element = element else {
            return FocusedElementResponse(element: nil, hasFocus: false)
        }
        let info = convertToElementInfo(element)
        return FocusedElementResponse(element: info, hasFocus: true)
    }

    private func convertToElementInfo(
        _ element: UIElement
    ) -> ElementInfo {
        let role: String = getAttribute(.role, from: element) ?? "Unknown"
        let title: String? = getAttribute(.title, from: element)
        let value: String? = getAttribute(.value, from: element)
        let actions = getActions(from: element)
        return ElementInfo(
            role: role,
            title: title,
            value: value,
            path: "focused",
            actions: actions
        )
    }

    private func getAttribute<T>(
        _ attr: ElementAttribute,
        from element: UIElement
    ) -> T? {
        try? bridge.getAttribute(attr, from: element)
    }

    private func getActions(from element: UIElement) -> [String] {
        let actions: [ElementAction] = (
            try? bridge.getActionNames(from: element)
        ) ?? []
        return actions.map { $0.rawValue }
    }
}
