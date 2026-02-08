import Foundation

extension TreeTraverser {
    func buildChildren(
        children: [UIElement],
        depth: Int,
        options: TreeTraversalOptions,
        bridge: any AXBridge,
        pathComponents: [String],
        role: String,
        deadline: Date,
        applicationPID: pid_t
    ) throws(TreeTraversalError) -> [TreeNode] {
        let parentPath = buildPath(components: pathComponents, role: role, applicationPID: applicationPID)
        return try processChildren(children, depth, options, bridge, parentPath, deadline, applicationPID)
    }

    func processChildren(
        _ children: [UIElement],
        _ depth: Int,
        _ options: TreeTraversalOptions,
        _ bridge: any AXBridge,
        _ parentPath: String,
        _ deadline: Date,
        _ applicationPID: pid_t
    ) throws(TreeTraversalError) -> [TreeNode] {
        var roleIndexes: [String: Int] = [:]
        return try collectChildNodes(children, depth, options, bridge, parentPath, deadline, applicationPID, &roleIndexes)
    }

    func collectChildNodes(
        _ children: [UIElement],
        _ depth: Int,
        _ options: TreeTraversalOptions,
        _ bridge: any AXBridge,
        _ parentPath: String,
        _ deadline: Date,
        _ applicationPID: pid_t,
        _ roleIndexes: inout [String: Int]
    ) throws(TreeTraversalError) -> [TreeNode] {
        var nodes: [TreeNode] = []
        for child in children {
            try appendChild(child, depth, options, bridge, parentPath, deadline, applicationPID, &roleIndexes, &nodes)
        }
        return nodes
    }

    func appendChild(
        _ child: UIElement,
        _ depth: Int,
        _ options: TreeTraversalOptions,
        _ bridge: any AXBridge,
        _ parentPath: String,
        _ deadline: Date,
        _ applicationPID: pid_t,
        _ roleIndexes: inout [String: Int],
        _ nodes: inout [TreeNode]
    ) throws(TreeTraversalError) {
        do {
            try appendValidChild(child, depth, options, bridge, parentPath, deadline, applicationPID, &roleIndexes, &nodes)
        } catch TreeTraversalError.timeoutExceeded {
            throw TreeTraversalError.timeoutExceeded(options.timeout)
        } catch {}
    }

    func appendValidChild(
        _ child: UIElement,
        _ depth: Int,
        _ options: TreeTraversalOptions,
        _ bridge: any AXBridge,
        _ parentPath: String,
        _ deadline: Date,
        _ applicationPID: pid_t,
        _ roleIndexes: inout [String: Int],
        _ nodes: inout [TreeNode]
    ) throws(TreeTraversalError) {
        let node = try buildChildNode(child, depth, options, bridge, parentPath, deadline, applicationPID, &roleIndexes)
        nodes.append(node)
    }

    func buildChildNode(
        _ child: UIElement,
        _ depth: Int,
        _ options: TreeTraversalOptions,
        _ bridge: any AXBridge,
        _ parentPath: String,
        _ deadline: Date,
        _ applicationPID: pid_t,
        _ roleIndexes: inout [String: Int]
    ) throws(TreeTraversalError) -> TreeNode {
        let childRole = try getChildRole(child, bridge: bridge)
        let index = nextIndex(for: childRole, in: &roleIndexes)
        let childPath = buildChildPath(parentPath: parentPath, role: childRole, index: index)
        return try buildNodeWithPath(element: child, depth: depth + 1, options: options, bridge: bridge, pathString: childPath, deadline: deadline, applicationPID: applicationPID)
    }
}

extension TreeTraverser {
    func nextIndex(
        for role: String,
        in roleIndexes: inout [String: Int]
    ) -> Int {
        let index = roleIndexes[role] ?? 0
        roleIndexes[role] = index + 1
        return index
    }

    func getChildRole(
        _ element: UIElement,
        bridge: any AXBridge
    ) throws(TreeTraversalError) -> String {
        do {
            return try bridge.getAttribute(.role, from: element)
        } catch {
            throw TreeTraversalError.accessibilityError(error)
        }
    }
}
