import Foundation

struct GetUITreeParameters: Codable, Sendable {
    let app: String
    let depth: Int?
    let includeAttributes: [String]?
    let filterRoles: [String]?

    init(
        app: String,
        depth: Int? = nil,
        includeAttributes: [String]? = nil,
        filterRoles: [String]? = nil
    ) {
        self.app = app
        self.depth = depth
        self.includeAttributes = includeAttributes
        self.filterRoles = filterRoles
    }

    func validate() throws(ToolParameterError) {
        let effectiveDepth = depth ?? 3
        guard effectiveDepth > 0 else {
            throw ToolParameterError.invalidValue(
                parameter: "depth",
                value: "\(effectiveDepth)",
                reason: "Depth must be greater than 0"
            )
        }
    }

    func effectiveDepth() -> Int {
        depth ?? 3
    }
}
