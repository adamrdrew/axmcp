import Foundation

struct ElementFinder: Sendable {
    private let traverser = TreeTraverser()

    func find(
        criteria: SearchCriteria,
        in element: UIElement,
        bridge: any AXBridge,
        applicationPID: pid_t
    ) throws(TreeTraversalError) -> [(UIElement, ElementPath)] {
        let options = createTraversalOptions(from: criteria)
        let tree = try traverser.traverse(
            element: element,
            options: options,
            bridge: bridge,
            applicationPID: applicationPID
        )
        return findMatches(in: tree, criteria: criteria, bridge: bridge)
    }

    private func createTraversalOptions(
        from criteria: SearchCriteria
    ) -> TreeTraversalOptions {
        TreeTraversalOptions(maxDepth: 10, timeout: 5.0)
    }

    private func findMatches(
        in tree: TreeNode,
        criteria: SearchCriteria,
        bridge: any AXBridge
    ) -> [(UIElement, ElementPath)] {
        var results: [(UIElement, ElementPath)] = []
        collectMatches(
            node: tree,
            criteria: criteria,
            results: &results,
            bridge: bridge
        )
        return Array(results.prefix(criteria.maxResults))
    }

    private func collectMatches(
        node: TreeNode,
        criteria: SearchCriteria,
        results: inout [(UIElement, ElementPath)],
        bridge: any AXBridge
    ) {
        if results.count >= criteria.maxResults { return }
        if matches(node: node, criteria: criteria) {
            if let element = resolveElement(from: node, bridge: bridge) {
                results.append((element, pathFromString(node.path)))
            }
        }
        for child in node.children {
            collectMatches(node: child, criteria: criteria, results: &results, bridge: bridge)
        }
    }
}
