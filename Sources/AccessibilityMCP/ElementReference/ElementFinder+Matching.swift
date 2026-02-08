import Foundation

extension ElementFinder {
    func matches(node: TreeNode, criteria: SearchCriteria) -> Bool {
        if !matchesRole(node: node, criteria: criteria) {
            return false
        }
        if !matchesTitle(node: node, criteria: criteria) {
            return false
        }
        if !matchesValue(node: node, criteria: criteria) {
            return false
        }
        return matchesIdentifier(node: node, criteria: criteria)
    }

    func matchesRole(node: TreeNode, criteria: SearchCriteria) -> Bool {
        guard let requiredRole = criteria.role else { return true }
        let nodeRole = ElementRole.from(string: node.role)
        return nodeRole == requiredRole
    }

    func matchesTitle(node: TreeNode, criteria: SearchCriteria) -> Bool {
        guard let substring = criteria.titleSubstring else { return true }
        guard let title = node.title else { return false }
        if criteria.caseSensitive {
            return title.contains(substring)
        } else {
            return title.localizedCaseInsensitiveContains(substring)
        }
    }

    func matchesValue(node: TreeNode, criteria: SearchCriteria) -> Bool {
        guard let requiredValue = criteria.value else { return true }
        guard let nodeValue = node.value else { return false }
        return nodeValue == requiredValue
    }

    func matchesIdentifier(node: TreeNode, criteria: SearchCriteria) -> Bool {
        guard criteria.identifier != nil else { return true }
        return false
    }

    func resolveElement(
        from node: TreeNode,
        bridge: any AXBridge
    ) -> UIElement? {
        do {
            let path = try ElementPath(parsing: node.path)
            let resolver = ElementResolver()
            return try resolver.resolve(path: path, bridge: bridge)
        } catch {
            return nil
        }
    }

    func pathFromString(_ string: String) -> ElementPath {
        (try? ElementPath(parsing: string)) ?? ElementPath(components: [])
    }
}
