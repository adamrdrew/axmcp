import Foundation

extension TreeTraverser {
    func buildChildren(
        children: [UIElement],
        depth: Int,
        options: TreeTraversalOptions,
        bridge: any AXBridge,
        pathComponents: [String],
        role: String,
        deadline: Date
    ) throws(TreeTraversalError) -> [TreeNode] {
        var nodes: [TreeNode] = []
        let newPath = pathComponents + [role]
        for child in children {
            do {
                let node = try buildNode(
                    element: child,
                    depth: depth + 1,
                    options: options,
                    bridge: bridge,
                    pathComponents: newPath,
                    deadline: deadline
                )
                nodes.append(node)
            } catch TreeTraversalError.timeoutExceeded {
                throw TreeTraversalError.timeoutExceeded(options.timeout)
            } catch {
                continue
            }
        }
        return nodes
    }

    func buildPath(components: [String], role: String) -> String {
        let allComponents = components + [role]
        return allComponents.joined(separator: "/")
    }
}
