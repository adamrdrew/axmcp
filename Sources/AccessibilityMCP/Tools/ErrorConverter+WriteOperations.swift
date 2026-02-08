import Foundation

extension ErrorConverter {
    static func convertElementPathError(
        _ error: ElementPathError,
        operation: String,
        app: String
    ) -> ToolExecutionError {
        let msg = elementPathMessage(error)
        let guide = elementPathGuidance(error)
        return ToolExecutionError.toolError(
            ToolError(
                operation: operation,
                errorType: "element_path_error",
                message: msg,
                app: app,
                guidance: guide
            )
        )
    }

    static func convertBlocklistError(
        _ error: BlocklistError,
        operation: String,
        app: String
    ) -> ToolExecutionError {
        let guide = blocklistGuidance(error)
        return ToolExecutionError.toolError(
            ToolError(
                operation: operation,
                errorType: "blocklisted_application",
                message: "Application '\(app)' is blocklisted for write operations",
                app: app,
                guidance: guide
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
                guidance: "Remove --read-only flag or unset ACCESSIBILITY_MCP_READ_ONLY environment variable to enable write operations."
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
                guidance: "Use get_ui_tree or find_element to check the 'actions' array for this element's supported actions."
            )
        )
    }
}
