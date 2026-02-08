import Foundation

enum ToolParameterError: Error, Sendable {
    case missingRequired(parameter: String)
    case invalidValue(parameter: String, value: String, reason: String)
    case invalidType(parameter: String, expected: String, actual: String)
}
