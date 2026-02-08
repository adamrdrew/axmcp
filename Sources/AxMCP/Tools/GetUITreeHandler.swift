import Foundation

struct GetUITreeHandler: Sendable {
    private let resolver: any AppResolver
    private let bridge: any AXBridge
    private let traverser = TreeTraverser()

    init(resolver: any AppResolver, bridge: any AXBridge) {
        self.resolver = resolver
        self.bridge = bridge
    }

    func execute(
        parameters: GetUITreeParameters
    ) throws(ToolExecutionError) -> UITreeResponse {
        do {
            try parameters.validate()
            let pid = try resolvePID(parameters.app)
            let element = try createAppElement(pid: pid)
            let options = createOptions(from: parameters)
            let tree = try executeTraversal(element, options, pid)
            return createResponse(tree: tree, parameters: parameters)
        } catch let error as AppResolutionError {
            throw ErrorConverter.convertAppError(error, operation: "get_ui_tree")
        } catch let error as ToolParameterError {
            throw ErrorConverter.convertParameterError(error, operation: "get_ui_tree")
        } catch let error as AccessibilityError {
            throw ErrorConverter.convertAccessibilityError(error, operation: "get_ui_tree", app: parameters.app)
        } catch let error as TreeTraversalError {
            throw ErrorConverter.convertTraversalError(error, operation: "get_ui_tree", app: parameters.app, guidance: "Reduce depth or filter roles")
        } catch {
            throw ToolExecutionError.toolError(
                ToolError(
                    operation: "get_ui_tree",
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

    private func createOptions(
        from params: GetUITreeParameters
    ) -> TreeTraversalOptions {
        let roles = params.filterRoles?.compactMap {
            ElementRole.from(string: $0)
        }
        let attrs = params.includeAttributes?.compactMap {
            ElementAttribute.from(string: $0)
        }
        return TreeTraversalOptions(
            maxDepth: params.effectiveDepth(),
            filterRoles: roles.map { Set($0) },
            includeAttributes: attrs.map { Set($0) },
            timeout: 5.0
        )
    }

    private func executeTraversal(
        _ element: UIElement,
        _ options: TreeTraversalOptions,
        _ pid: pid_t
    ) throws(TreeTraversalError) -> TreeNode {
        try traverser.traverse(
            element: element,
            options: options,
            bridge: bridge,
            applicationPID: pid
        )
    }

    private func createResponse(
        tree: TreeNode,
        parameters: GetUITreeParameters
    ) -> UITreeResponse {
        UITreeResponse(
            tree: tree,
            hasMoreResults: false,
            resultCount: countNodes(tree),
            depth: parameters.effectiveDepth()
        )
    }

    private func countNodes(_ node: TreeNode) -> Int {
        1 + node.children.reduce(0) { $0 + countNodes($1) }
    }
}
