import Foundation

extension ErrorConverter {
    static func convertElementPathError(
        _ error: ElementPathError,
        operation: String,
        app: String
    ) -> ToolExecutionError {
        ToolExecutionError.toolError(
            ToolError(
                operation: operation,
                errorType: "element_path_error",
                message: "Element path error: \(error)",
                app: app,
                guidance: "Check element path syntax and ensure element exists"
            )
        )
    }

    static func convertBlocklistError(
        _ error: BlocklistError,
        operation: String,
        app: String
    ) -> ToolExecutionError {
        ToolExecutionError.toolError(
            ToolError(
                operation: operation,
                errorType: "blocklisted_application",
                message: "Application '\(app)' is blocklisted for write operations",
                app: app,
                guidance: error.guidance
            )
        )
    }

    static func convertReadOnlyError(
        operation: String
    ) -> ToolExecutionError {
        ToolExecutionError.toolError(
            ToolError(
                operation: operation,
                errorType: "read_only_mode",
                message: "Write operations are disabled in read-only mode",
                guidance: "Remove --read-only flag or ACCESSIBILITY_MCP_READ_ONLY env var"
            )
        )
    }

    static func convertActionError(
        operation: String,
        action: String,
        app: String
    ) -> ToolExecutionError {
        ToolExecutionError.toolError(
            ToolError(
                operation: operation,
                errorType: "action_not_supported",
                message: "Element does not support action '\(action)'",
                app: app,
                guidance: "Check available actions for this element"
            )
        )
    }
}
