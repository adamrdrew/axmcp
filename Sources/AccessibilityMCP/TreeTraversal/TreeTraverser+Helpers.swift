import Foundation

extension TreeTraverser {
    func getTitle(
        element: UIElement,
        bridge: any AXBridge,
        options: TreeTraversalOptions
    ) -> String? {
        guard shouldIncludeAttribute(.title, options: options) else {
            return nil
        }
        return try? bridge.getAttribute(.title, from: element)
    }

    func getValue(
        element: UIElement,
        bridge: any AXBridge,
        options: TreeTraversalOptions
    ) -> String? {
        guard shouldIncludeAttribute(.value, options: options) else {
            return nil
        }
        return try? bridge.getAttribute(.value, from: element)
    }

    func getActions(
        element: UIElement,
        bridge: any AXBridge
    ) -> [String] {
        guard let actions = try? bridge.getActionNames(from: element) else {
            return []
        }
        return actions.map { $0.rawValue }
    }

    func getChildCount(
        element: UIElement,
        bridge: any AXBridge
    ) -> Int {
        guard let children = try? bridge.getChildren(from: element) else {
            return 0
        }
        return children.count
    }

    func shouldIncludeAttribute(
        _ attribute: ElementAttribute,
        options: TreeTraversalOptions
    ) -> Bool {
        guard let includeAttributes = options.includeAttributes else {
            return true
        }
        return includeAttributes.contains(attribute)
    }

    func getNodeChildren(
        element: UIElement,
        depth: Int,
        options: TreeTraversalOptions,
        bridge: any AXBridge,
        pathComponents: [String],
        role: String,
        deadline: Date
    ) throws(TreeTraversalError) -> [TreeNode] {
        guard depth + 1 < options.maxDepth else { return [] }
        guard let children = try? bridge.getChildren(from: element) else {
            return []
        }
        return try buildChildren(
            children: children,
            depth: depth,
            options: options,
            bridge: bridge,
            pathComponents: pathComponents,
            role: role,
            deadline: deadline
        )
    }
}
