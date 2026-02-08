import Foundation

struct ActionResponse: Codable, Sendable {
    let success: Bool
    let action: String
    let elementState: ElementStateInfo
    let rateLimitWarning: String?

    init(
        success: Bool,
        action: String,
        elementState: ElementStateInfo,
        rateLimitWarning: String? = nil
    ) {
        self.success = success
        self.action = action
        self.elementState = elementState
        self.rateLimitWarning = rateLimitWarning
    }
}
