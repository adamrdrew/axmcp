import Foundation

struct ErrorConverter: Sendable {
    static func convertAppError(
        _ error: AppResolutionError,
        operation: String
    ) -> ToolExecutionError {
        switch error {
        case .notRunning(let app):
            return ToolExecutionError.toolError(
                ToolError(
                    operation: operation,
                    errorType: "app_not_running",
                    message: "Application '\(app)' is not running",
                    app: app,
                    guidance: "Start the application and try again"
                )
            )
        case .multipleMatches(let app, let matches):
            return ToolExecutionError.toolError(
                ToolError(
                    operation: operation,
                    errorType: "multiple_matches",
                    message: "Multiple apps match '\(app)': \(matches.joined(separator: ", "))",
                    app: app,
                    guidance: "Use a more specific app name"
                )
            )
        case .invalidIdentifier(let id):
            return ToolExecutionError.toolError(
                ToolError(
                    operation: operation,
                    errorType: "invalid_identifier",
                    message: "Invalid app identifier: '\(id)'",
                    guidance: "Provide a valid app name or PID"
                )
            )
        }
    }

    static func convertParameterError(
        _ error: ToolParameterError,
        operation: String
    ) -> ToolExecutionError {
        ToolExecutionError.toolError(
            ToolError(
                operation: operation,
                errorType: "invalid_parameter",
                message: "Invalid parameter: \(error)",
                guidance: "Check parameter values"
            )
        )
    }

    static func convertAccessibilityError(
        _ error: AccessibilityError,
        operation: String,
        app: String?
    ) -> ToolExecutionError {
        switch error {
        case .permissionDenied(let guidance):
            return ToolExecutionError.toolError(
                ToolError(
                    operation: operation,
                    errorType: "permission_denied",
                    message: "Accessibility permissions not granted",
                    app: app,
                    guidance: guidance
                )
            )
        default:
            return ToolExecutionError.toolError(
                ToolError(
                    operation: operation,
                    errorType: "accessibility_error",
                    message: "Accessibility error: \(error)",
                    app: app
                )
            )
        }
    }

    static func convertTraversalError(
        _ error: TreeTraversalError,
        operation: String,
        app: String,
        guidance: String
    ) -> ToolExecutionError {
        switch error {
        case .timeoutExceeded(let timeout):
            return ToolExecutionError.toolError(
                ToolError(
                    operation: operation,
                    errorType: "timeout",
                    message: "\(operation) exceeded \(timeout)s timeout",
                    app: app,
                    guidance: guidance
                )
            )
        default:
            return ToolExecutionError.toolError(
                ToolError(
                    operation: operation,
                    errorType: "traversal_error",
                    message: "\(operation) failed: \(error)",
                    app: app
                )
            )
        }
    }
}
