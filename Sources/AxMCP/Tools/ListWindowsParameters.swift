import Foundation

struct ListWindowsParameters: Codable, Sendable {
    let app: String?
    let includeMinimized: Bool?

    init(app: String? = nil, includeMinimized: Bool? = nil) {
        self.app = app
        self.includeMinimized = includeMinimized
    }

    func validate() throws(ToolParameterError) {
    }

    func effectiveIncludeMinimized() -> Bool {
        includeMinimized ?? false
    }
}
