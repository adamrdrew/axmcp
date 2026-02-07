import Foundation

struct ElementStateInfo: Codable, Sendable {
    let role: String?
    let title: String?
    let value: String?
    let enabled: Bool?
    let focused: Bool?
    let actions: [String]
    let path: String

    init(
        role: String?,
        title: String?,
        value: String?,
        enabled: Bool?,
        focused: Bool?,
        actions: [String],
        path: String
    ) {
        self.role = role
        self.title = title
        self.value = value
        self.enabled = enabled
        self.focused = focused
        self.actions = actions
        self.path = path
    }
}
