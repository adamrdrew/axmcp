import Foundation

struct SetValueParameters: Codable, Sendable {
    let app: String
    let elementPath: String
    let value: AnyCodableValue

    init(
        app: String,
        elementPath: String,
        value: AnyCodableValue
    ) {
        self.app = app
        self.elementPath = elementPath
        self.value = value
    }

    func validate() throws(ToolParameterError) {
        guard !app.isEmpty else {
            throw ToolParameterError.missingRequired(
                parameter: "app"
            )
        }
        guard !elementPath.isEmpty else {
            throw ToolParameterError.missingRequired(
                parameter: "elementPath"
            )
        }
    }
}
