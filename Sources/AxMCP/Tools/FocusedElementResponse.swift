import Foundation

struct FocusedElementResponse: Codable, Sendable {
    let element: ElementInfo?
    let hasFocus: Bool

    init(element: ElementInfo?, hasFocus: Bool) {
        self.element = element
        self.hasFocus = hasFocus
    }
}
