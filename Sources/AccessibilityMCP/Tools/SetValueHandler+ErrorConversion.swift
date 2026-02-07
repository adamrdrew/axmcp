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
        ToolExecutionError.toolError(
            ToolError(
                operation: "set_value",
                errorType: "blocklisted_application",
                message: "Application '\(params.app)' is blocklisted for write operations",
                app: params.app,
                guidance: error.guidance
            )
        )
    }

    func convertPathError(
        _ error: ElementPathError,
        _ params: SetValueParameters
    ) -> ToolExecutionError {
        ToolExecutionError.toolError(
            ToolError(
                operation: "set_value",
                errorType: "element_path_error",
                message: "Failed to resolve element path: \(error)",
                app: params.app,
                guidance: "Check element path syntax and ensure element exists"
            )
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
                app: params.app
            )
        )
    }
}
