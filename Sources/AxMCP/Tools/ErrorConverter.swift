import Foundation

struct ErrorConverter: Sendable {
    static func convertAppError(
        _ error: AppResolutionError,
        operation: String
    ) -> ToolExecutionError {
        let pair = appErrorContent(error)
        return ToolExecutionError.toolError(
            ToolError(
                operation: operation,
                errorType: pair.errorType,
                message: pair.message,
                app: pair.app,
                guidance: pair.guidance
            )
        )
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
                guidance: "Check parameter names and types against the tool schema."
            )
        )
    }
}

extension ErrorConverter {
    private static func appErrorContent(
        _ error: AppResolutionError
    ) -> (errorType: String, message: String, app: String?, guidance: String) {
        switch error {
        case .notRunning(let app):
            return ("app_not_running", "Application '\(app)' is not running", app,
                    "Start the application and try again. Use the exact app name as it appears in the Dock or Activity Monitor.")
        case .multipleMatches(let app, let matches):
            let names = matches.joined(separator: ", ")
            return ("multiple_matches", "Multiple apps match '\(app)': \(names)", app,
                    "Use a more specific name. Running matches: \(names)")
        case .invalidIdentifier(let id):
            return ("invalid_identifier", "Invalid app identifier: '\(id)'", nil,
                    "Provide a valid app name (e.g. \"Finder\") or numeric PID.")
        }
    }
}
