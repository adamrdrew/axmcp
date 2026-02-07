import Foundation

struct TreeTraverser: Sendable {
    func traverse(
        element: UIElement,
        options: TreeTraversalOptions,
        bridge: any AXBridge
    ) throws(TreeTraversalError) -> TreeNode {
        try validate(options: options)
        let deadline = Date().addingTimeInterval(options.timeout)
        return try buildNode(
            element: element,
            depth: 0,
            options: options,
            bridge: bridge,
            pathComponents: [],
            deadline: deadline
        )
    }
}

extension TreeTraverser {
    private func validate(
        options: TreeTraversalOptions
    ) throws(TreeTraversalError) {
        guard options.maxDepth >= 1 else {
            throw TreeTraversalError.invalidDepth(options.maxDepth)
        }
    }

    func buildNode(
        element: UIElement,
        depth: Int,
        options: TreeTraversalOptions,
        bridge: any AXBridge,
        pathComponents: [String],
        deadline: Date
    ) throws(TreeTraversalError) -> TreeNode {
        try checkTimeout(deadline: deadline, timeout: options.timeout)
        let role = try getRole(element: element, bridge: bridge)
        if depth > 0 && shouldFilter(role: role, options: options) {
            throw TreeTraversalError.invalidElement
        }
        return try createNode(
            element: element,
            role: role,
            depth: depth,
            options: options,
            bridge: bridge,
            pathComponents: pathComponents,
            deadline: deadline
        )
    }

    private func checkTimeout(
        deadline: Date,
        timeout: TimeInterval
    ) throws(TreeTraversalError) {
        guard Date() <= deadline else {
            throw TreeTraversalError.timeoutExceeded(timeout)
        }
    }

    private func getRole(
        element: UIElement,
        bridge: any AXBridge
    ) throws(TreeTraversalError) -> String {
        do {
            return try bridge.getAttribute(.role, from: element)
        } catch {
            throw TreeTraversalError.accessibilityError(error)
        }
    }

    private func shouldFilter(
        role: String,
        options: TreeTraversalOptions
    ) -> Bool {
        guard let filterRoles = options.filterRoles else {
            return false
        }
        return !filterRoles.contains(ElementRole.from(string: role))
    }

    private func createNode(
        element: UIElement,
        role: String,
        depth: Int,
        options: TreeTraversalOptions,
        bridge: any AXBridge,
        pathComponents: [String],
        deadline: Date
    ) throws(TreeTraversalError) -> TreeNode {
        TreeNode(
            role: role,
            title: getTitle(element: element, bridge: bridge, options: options),
            value: getValue(element: element, bridge: bridge, options: options),
            children: try getNodeChildren(
                element: element,
                depth: depth,
                options: options,
                bridge: bridge,
                pathComponents: pathComponents,
                role: role,
                deadline: deadline
            ),
            actions: getActions(element: element, bridge: bridge),
            path: buildPath(components: pathComponents, role: role),
            childCount: getChildCount(element: element, bridge: bridge),
            depth: depth
        )
    }
}
