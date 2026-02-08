import Foundation

extension SetValueHandler {
    func convertParameterError(
        _ error: ToolParameterError,
        _ params: SetValueParameters
    ) -> ToolExecutionError {
        ErrorConverter.convertParameterError(
            error,
            operation: "set_value"
        )
    }

    func convertAppError(
        _ error: AppResolutionError,
        _ params: SetValueParameters
    ) -> ToolExecutionError {
        ErrorConverter.convertAppError(
            error,
            operation: "set_value"
        )
    }

    func convertBlocklistError(
        _ error: BlocklistError,
        _ params: SetValueParameters
    ) -> ToolExecutionError {
        ErrorConverter.convertBlocklistError(
            error,
            operation: "set_value",
            app: params.app
        )
    }

    func convertPathError(
        _ error: ElementPathError,
        _ params: SetValueParameters
    ) -> ToolExecutionError {
        ErrorConverter.convertElementPathError(
            error,
            operation: "set_value",
            app: params.app
        )
    }

    func convertAccessibilityError(
        _ error: AccessibilityError,
        _ params: SetValueParameters
    ) -> ToolExecutionError {
        ErrorConverter.convertAccessibilityError(
            error,
            operation: "set_value",
            app: params.app
        )
    }

    func createUnknownError(
        _ error: Error,
        _ params: SetValueParameters
    ) -> ToolExecutionError {
        ToolExecutionError.toolError(
            ToolError(
                operation: "set_value",
                errorType: "unknown_error",
                message: "Unexpected error: \(error)",
                app: params.app,
                guidance: "This is an unexpected error. Check that the application is running and permissions are granted."
            )
        )
    }
}
