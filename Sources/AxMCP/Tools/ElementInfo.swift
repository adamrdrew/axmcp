import Foundation

struct ElementInfo: Codable, Sendable {
    let role: String
    let title: String?
    let value: String?
    let path: String
    let actions: [String]

    init(
        role: String,
        title: String?,
        value: String?,
        path: String,
        actions: [String]
    ) {
        self.role = role
        self.title = title
        self.value = value
        self.path = path
        self.actions = actions
    }
}
