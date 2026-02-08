import Foundation

extension PerformActionHandler {
    func convertParameterError(
        _ error: ToolParameterError,
        _ params: PerformActionParameters
    ) -> ToolExecutionError {
        ErrorConverter.convertParameterError(
            error,
            operation: "perform_action"
        )
    }

    func convertAppError(
        _ error: AppResolutionError,
        _ params: PerformActionParameters
    ) -> ToolExecutionError {
        ErrorConverter.convertAppError(
            error,
            operation: "perform_action"
        )
    }

    func convertBlocklistError(
        _ error: BlocklistError,
        _ params: PerformActionParameters
    ) -> ToolExecutionError {
        ErrorConverter.convertBlocklistError(
            error,
            operation: "perform_action",
            app: params.app
        )
    }

    func convertPathError(
        _ error: ElementPathError,
        _ params: PerformActionParameters
    ) -> ToolExecutionError {
        ErrorConverter.convertElementPathError(
            error,
            operation: "perform_action",
            app: params.app
        )
    }

    func convertAccessibilityError(
        _ error: AccessibilityError,
        _ params: PerformActionParameters
    ) -> ToolExecutionError {
        if case .actionUnsupported = error {
            return ErrorConverter.convertActionError(
                operation: "perform_action",
                action: params.action,
                app: params.app
            )
        }
        return ErrorConverter.convertAccessibilityError(
            error,
            operation: "perform_action",
            app: params.app
        )
    }

    func createUnknownError(
        _ error: Error,
        _ params: PerformActionParameters
    ) -> ToolExecutionError {
        ToolExecutionError.toolError(
            ToolError(
                operation: "perform_action",
                errorType: "unknown_error",
                message: "Unexpected error: \(error)",
                app: params.app,
                guidance: "This is an unexpected error. Check that the application is running and permissions are granted."
            )
        )
    }
}
