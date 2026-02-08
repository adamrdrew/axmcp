import Foundation

extension TreeTraverser {
    func buildNodeWithPath(
        element: UIElement,
        depth: Int,
        options: TreeTraversalOptions,
        bridge: any AXBridge,
        pathString: String,
        deadline: Date,
        applicationPID: pid_t
    ) throws(TreeTraversalError) -> TreeNode {
        try checkTimeoutInternal(deadline: deadline, timeout: options.timeout)
        let role = try getRoleInternal(element: element, bridge: bridge)
        if depth > 0 && shouldFilterInternal(role: role, options: options) {
            throw TreeTraversalError.invalidElement
        }
        return try createNodeWithPath(
            element: element,
            role: role,
            depth: depth,
            options: options,
            bridge: bridge,
            pathString: pathString,
            deadline: deadline,
            applicationPID: applicationPID
        )
    }

    func createNodeWithPath(
        element: UIElement,
        role: String,
        depth: Int,
        options: TreeTraversalOptions,
        bridge: any AXBridge,
        pathString: String,
        deadline: Date,
        applicationPID: pid_t
    ) throws(TreeTraversalError) -> TreeNode {
        TreeNode(
            role: role,
            title: getTitle(element: element, bridge: bridge, options: options),
            value: getValue(element: element, bridge: bridge, options: options),
            children: try getNodeChildrenWithPath(
                element: element,
                depth: depth,
                options: options,
                bridge: bridge,
                pathString: pathString,
                role: role,
                deadline: deadline,
                applicationPID: applicationPID
            ),
            actions: getActions(element: element, bridge: bridge),
            path: pathString,
            childCount: getChildCount(element: element, bridge: bridge),
            depth: depth
        )
    }

    func getNodeChildrenWithPath(
        element: UIElement,
        depth: Int,
        options: TreeTraversalOptions,
        bridge: any AXBridge,
        pathString: String,
        role: String,
        deadline: Date,
        applicationPID: pid_t
    ) throws(TreeTraversalError) -> [TreeNode] {
        guard depth + 1 < options.maxDepth else { return [] }
        guard let children = try? bridge.getChildren(from: element) else {
            return []
        }
        return try buildChildrenWithPath(
            children: children,
            depth: depth,
            options: options,
            bridge: bridge,
            parentPath: pathString,
            deadline: deadline,
            applicationPID: applicationPID
        )
    }

    func buildChildrenWithPath(
        children: [UIElement],
        depth: Int,
        options: TreeTraversalOptions,
        bridge: any AXBridge,
        parentPath: String,
        deadline: Date,
        applicationPID: pid_t
    ) throws(TreeTraversalError) -> [TreeNode] {
        try processChildren(children, depth, options, bridge, parentPath, deadline, applicationPID)
    }
}

extension TreeTraverser {
    func checkTimeoutInternal(
        deadline: Date,
        timeout: TimeInterval
    ) throws(TreeTraversalError) {
        guard Date() <= deadline else {
            throw TreeTraversalError.timeoutExceeded(timeout)
        }
    }

    func getRoleInternal(
        element: UIElement,
        bridge: any AXBridge
    ) throws(TreeTraversalError) -> String {
        do {
            return try bridge.getAttribute(.role, from: element)
        } catch {
            throw TreeTraversalError.accessibilityError(error)
        }
    }

    func shouldFilterInternal(
        role: String,
        options: TreeTraversalOptions
    ) -> Bool {
        guard let filterRoles = options.filterRoles else {
            return false
        }
        return !filterRoles.contains(ElementRole.from(string: role))
    }
}
