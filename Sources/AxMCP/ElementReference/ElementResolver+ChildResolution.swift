import Foundation

extension ElementResolver {
    func resolveChildByRole(
        _ role: ElementRole,
        index: Int,
        from element: UIElement,
        bridge: any AXBridge
    ) throws(ElementPathError) -> UIElement {
        let children: [UIElement]
        do {
            children = try bridge.getChildren(from: element)
        } catch {
            throw ElementPathError.accessibilityError(error)
        }
        let matching = children.filter { child in
            isMatchingRole(child, role: role, bridge: bridge)
        }
        guard index < matching.count else {
            let available = matching.compactMap { getChildDescription($0, bridge: bridge) }
            throw ElementPathError.componentNotFound(
                .childByRole(role, index: index),
                available: available
            )
        }
        return matching[index]
    }

    func resolveChildByRoleAndTitle(
        _ role: ElementRole,
        title: String,
        from element: UIElement,
        bridge: any AXBridge
    ) throws(ElementPathError) -> UIElement {
        let children: [UIElement]
        do {
            children = try bridge.getChildren(from: element)
        } catch {
            throw ElementPathError.accessibilityError(error)
        }
        for child in children {
            if isMatchingRole(child, role: role, bridge: bridge),
               isMatchingTitle(child, title: title, bridge: bridge) {
                return child
            }
        }
        let available = children.compactMap { getChildDescription($0, bridge: bridge) }
        throw ElementPathError.componentNotFound(
            .childByRoleAndTitle(role, title: title),
            available: available
        )
    }

    func isMatchingRole(
        _ element: UIElement,
        role: ElementRole,
        bridge: any AXBridge
    ) -> Bool {
        guard let elementRole: String = try? bridge.getAttribute(.role, from: element) else {
            return false
        }
        return ElementRole.from(string: elementRole) == role
    }

    func isMatchingTitle(
        _ element: UIElement,
        title: String,
        bridge: any AXBridge
    ) -> Bool {
        guard let elementTitle: String = try? bridge.getAttribute(.title, from: element) else {
            return false
        }
        return elementTitle == title
    }

    func getChildDescription(
        _ element: UIElement,
        bridge: any AXBridge
    ) -> String? {
        guard let role: String = try? bridge.getAttribute(.role, from: element) else {
            return nil
        }
        let title: String? = try? bridge.getAttribute(.title, from: element)
        return title.map { "\(role)[\"\($0)\"]" } ?? role
    }
}
