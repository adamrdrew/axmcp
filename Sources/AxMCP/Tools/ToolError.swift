import Foundation

struct ToolError: Codable, Sendable {
    let operation: String
    let errorType: String
    let message: String
    let app: String?
    let guidance: String?

    init(
        operation: String,
        errorType: String,
        message: String,
        app: String? = nil,
        guidance: String? = nil
    ) {
        self.operation = operation
        self.errorType = errorType
        self.message = message
        self.app = app
        self.guidance = guidance
    }
}
