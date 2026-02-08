import Foundation
import ApplicationServices

struct UIElement: @unchecked Sendable {
    private let element: AXUIElement

    init(_ element: AXUIElement) {
        self.element = element
    }

    var rawElement: AXUIElement {
        element
    }
}

extension UIElement {
    func withElement<T>(
        _ body: (AXUIElement) throws -> T
    ) rethrows -> T {
        try body(element)
    }
}
