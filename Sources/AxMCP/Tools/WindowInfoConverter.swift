import Foundation

struct WindowInfoConverter: Sendable {
    private let bridge: any AXBridge

    init(bridge: any AXBridge) {
        self.bridge = bridge
    }

    func convert(
        _ element: UIElement,
        appName: String
    ) -> WindowInfo? {
        guard let title: String = getAttribute(.title, from: element) else {
            return nil
        }
        return WindowInfo(
            title: title,
            position: getPosition(from: element),
            size: getSize(from: element),
            minimized: isMinimized(element),
            frontmost: isFrontmost(element),
            app: appName
        )
    }

    private func getPosition(
        from element: UIElement
    ) -> WindowInfo.Position {
        WindowInfo.Position(x: 0, y: 0)
    }

    private func getSize(from element: UIElement) -> WindowInfo.Size {
        WindowInfo.Size(width: 0, height: 0)
    }

    private func isMinimized(_ element: UIElement) -> Bool {
        false
    }

    private func isFrontmost(_ element: UIElement) -> Bool {
        false
    }

    private func getAttribute<T>(
        _ attr: ElementAttribute,
        from element: UIElement
    ) -> T? {
        try? bridge.getAttribute(attr, from: element)
    }
}
