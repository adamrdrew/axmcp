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
        ToolExecutionError.toolError(
            ToolError(
                operation: "perform_action",
                errorType: "blocklisted_application",
                message: "Application '\(params.app)' is blocklisted for write operations",
                app: params.app,
                guidance: error.guidance
            )
        )
    }

    func convertPathError(
        _ error: ElementPathError,
        _ params: PerformActionParameters
    ) -> ToolExecutionError {
        ToolExecutionError.toolError(
            ToolError(
                operation: "perform_action",
                errorType: "element_path_error",
                message: "Failed to resolve element path: \(error)",
                app: params.app,
                guidance: "Check element path syntax and ensure element exists"
            )
        )
    }

    func convertAccessibilityError(
        _ error: AccessibilityError,
        _ params: PerformActionParameters
    ) -> ToolExecutionError {
        if case .actionUnsupported = error {
            return ToolExecutionError.toolError(
                ToolError(
                    operation: "perform_action",
                    errorType: "action_not_supported",
                    message: "Element does not support action '\(params.action)'",
                    app: params.app,
                    guidance: "Check available actions for this element"
                )
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
                app: params.app
            )
        )
    }
}
