import Foundation

struct FindElementHandler: Sendable {
    private let resolver: any AppResolver
    private let bridge: any AXBridge
    private let finder = ElementFinder()

    init(resolver: any AppResolver, bridge: any AXBridge) {
        self.resolver = resolver
        self.bridge = bridge
    }

    func execute(
        parameters: FindElementParameters
    ) throws(ToolExecutionError) -> FindElementResponse {
        do {
            try parameters.validate()
            let pid = try resolvePID(parameters.app)
            let element = try createAppElement(pid: pid)
            let criteria = createCriteria(from: parameters)
            let results = try findElements(in: element, criteria)
            return createResponse(results, criteria, parameters)
        } catch let error as AppResolutionError {
            throw ErrorConverter.convertAppError(error, operation: "find_element")
        } catch let error as ToolParameterError {
            throw ErrorConverter.convertParameterError(error, operation: "find_element")
        } catch let error as AccessibilityError {
            throw ErrorConverter.convertAccessibilityError(error, operation: "find_element", app: parameters.app)
        } catch let error as TreeTraversalError {
            throw ErrorConverter.convertTraversalError(error, operation: "find_element", app: parameters.app, guidance: "Narrow search criteria")
        } catch {
            throw ToolExecutionError.toolError(
                ToolError(
                    operation: "find_element",
                    errorType: "unknown_error",
                    message: "Unexpected error: \(error)",
                    app: parameters.app
                )
            )
        }
    }

    private func resolvePID(
        _ appIdentifier: String
    ) throws(AppResolutionError) -> pid_t {
        try resolver.resolve(appIdentifier: appIdentifier)
    }

    private func createAppElement(
        pid: pid_t
    ) throws(AccessibilityError) -> UIElement {
        try bridge.createApplicationElement(pid: pid)
    }

    private func createCriteria(
        from params: FindElementParameters
    ) -> SearchCriteria {
        SearchCriteria(
            role: params.role.map { ElementRole.from(string: $0) },
            titleSubstring: params.title,
            value: params.value,
            identifier: params.identifier,
            caseSensitive: false,
            maxResults: params.effectiveMaxResults()
        )
    }

    private func findElements(
        in element: UIElement,
        _ criteria: SearchCriteria
    ) throws(TreeTraversalError) -> [(UIElement, ElementPath)] {
        try finder.find(criteria: criteria, in: element, bridge: bridge)
    }

    private func createResponse(
        _ results: [(UIElement, ElementPath)],
        _ criteria: SearchCriteria,
        _ parameters: FindElementParameters
    ) -> FindElementResponse {
        let matches = results.map { convertToMatch($0, $1) }
        return FindElementResponse(
            elements: matches,
            hasMoreResults: results.count >= criteria.maxResults,
            resultCount: results.count
        )
    }

    private func convertToMatch(
        _ element: UIElement,
        _ path: ElementPath
    ) -> ElementMatch {
        let role: String = getAttribute(.role, from: element) ?? "Unknown"
        let title: String? = getAttribute(.title, from: element)
        let value: String? = getAttribute(.value, from: element)
        return ElementMatch(
            role: role,
            title: title,
            value: value,
            path: path.toString()
        )
    }

    private func getAttribute<T>(
        _ attr: ElementAttribute,
        from element: UIElement
    ) -> T? {
        try? bridge.getAttribute(attr, from: element)
    }
}
