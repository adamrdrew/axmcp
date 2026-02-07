import Foundation

struct GetFocusedElementParameters: Codable, Sendable {
    let app: String?

    init(app: String? = nil) {
        self.app = app
    }

    func validate() throws(ToolParameterError) {
    }
}
