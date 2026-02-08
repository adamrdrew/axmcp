import Foundation

struct SetValueResponse: Codable, Sendable {
    let success: Bool
    let previousValue: String?
    let newValue: String?
    let elementState: ElementStateInfo
    let rateLimitWarning: String?

    init(
        success: Bool,
        previousValue: String?,
        newValue: String?,
        elementState: ElementStateInfo,
        rateLimitWarning: String? = nil
    ) {
        self.success = success
        self.previousValue = previousValue
        self.newValue = newValue
        self.elementState = elementState
        self.rateLimitWarning = rateLimitWarning
    }
}
