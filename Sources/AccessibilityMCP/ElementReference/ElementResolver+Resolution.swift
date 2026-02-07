import Foundation

extension ElementResolver {
    func resolveFirst(
        _ component: ElementPathComponent,
        bridge: any AXBridge
    ) throws(ElementPathError) -> UIElement {
        switch component {
        case .appByPID(let pid):
            do {
                return try bridge.createApplicationElement(pid: pid)
            } catch {
                throw ElementPathError.accessibilityError(error)
            }
        case .appByName:
            throw ElementPathError.invalidFormat("App by name not yet supported")
        default:
            throw ElementPathError.invalidFormat("First component must be app")
        }
    }

    func resolveNext(
        component: ElementPathComponent,
        from element: UIElement,
        bridge: any AXBridge
    ) throws(ElementPathError) -> UIElement {
        switch component {
        case .windowByIndex(let index):
            return try resolveWindowByIndex(index, from: element, bridge: bridge)
        case .windowByTitle(let title):
            return try resolveWindowByTitle(title, from: element, bridge: bridge)
        case .childByRole(let role, let index):
            return try resolveChildByRole(role, index: index, from: element, bridge: bridge)
        case .childByRoleAndTitle(let role, let title):
            return try resolveChildByRoleAndTitle(
                role,
                title: title,
                from: element,
                bridge: bridge
            )
        default:
            throw ElementPathError.invalidFormat("Invalid component in path")
        }
    }

    func resolveWindowByIndex(
        _ index: Int,
        from element: UIElement,
        bridge: any AXBridge
    ) throws(ElementPathError) -> UIElement {
        let windows: [UIElement]
        do {
            windows = try bridge.getAttribute(.windows, from: element)
        } catch {
            throw ElementPathError.accessibilityError(error)
        }
        guard index < windows.count else {
            let titles = windows.compactMap { try? getTitleString($0, bridge: bridge) }
            throw ElementPathError.componentNotFound(
                .windowByIndex(index),
                available: titles
            )
        }
        return windows[index]
    }

    func resolveWindowByTitle(
        _ title: String,
        from element: UIElement,
        bridge: any AXBridge
    ) throws(ElementPathError) -> UIElement {
        let windows: [UIElement]
        do {
            windows = try bridge.getAttribute(.windows, from: element)
        } catch {
            throw ElementPathError.accessibilityError(error)
        }
        for window in windows {
            if let windowTitle: String = try? bridge.getAttribute(.title, from: window),
               windowTitle == title {
                return window
            }
        }
        let titles = windows.compactMap { try? getTitleString($0, bridge: bridge) }
        throw ElementPathError.componentNotFound(.windowByTitle(title), available: titles)
    }

    func getTitleString(
        _ element: UIElement,
        bridge: any AXBridge
    ) throws -> String {
        try bridge.getAttribute(.title, from: element)
    }
}
