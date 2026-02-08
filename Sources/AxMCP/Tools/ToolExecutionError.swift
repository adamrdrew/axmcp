import Foundation

enum ToolExecutionError: Error, Sendable {
    case toolError(ToolError)
}
