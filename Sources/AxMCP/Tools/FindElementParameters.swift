import Foundation

struct FindElementParameters: Codable, Sendable {
    let app: String
    let role: String?
    let title: String?
    let value: String?
    let identifier: String?
    let maxResults: Int?

    init(
        app: String,
        role: String? = nil,
        title: String? = nil,
        value: String? = nil,
        identifier: String? = nil,
        maxResults: Int? = nil
    ) {
        self.app = app
        self.role = role
        self.title = title
        self.value = value
        self.identifier = identifier
        self.maxResults = maxResults
    }

    func validate() throws(ToolParameterError) {
        let effectiveMax = maxResults ?? 20
        guard effectiveMax > 0 else {
            throw ToolParameterError.invalidValue(
                parameter: "maxResults",
                value: "\(effectiveMax)",
                reason: "maxResults must be greater than 0"
            )
        }
    }

    func effectiveMaxResults() -> Int {
        maxResults ?? 20
    }
}
