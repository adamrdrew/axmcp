import Foundation

extension ErrorConverter {
    static func convertAccessibilityError(
        _ error: AccessibilityError,
        operation: String,
        app: String?
    ) -> ToolExecutionError {
        let pair = accessibilityErrorContent(error)
        return ToolExecutionError.toolError(
            ToolError(
                operation: operation,
                errorType: pair.errorType,
                message: pair.message,
                app: app,
                guidance: pair.guidance
            )
        )
    }

    static func convertTraversalError(
        _ error: TreeTraversalError,
        operation: String,
        app: String,
        guidance: String
    ) -> ToolExecutionError {
        let pair = traversalErrorContent(error, operation: operation, fallbackGuidance: guidance)
        return ToolExecutionError.toolError(
            ToolError(
                operation: operation,
                errorType: pair.errorType,
                message: pair.message,
                app: app,
                guidance: pair.guidance
            )
        )
    }
}

extension ErrorConverter {
    private static func accessibilityErrorContent(
        _ error: AccessibilityError
    ) -> (errorType: String, message: String, guidance: String) {
        switch error {
        case .permissionDenied(let guidance):
            return ("permission_denied", "Accessibility permissions not granted", guidance)
        case .invalidUIElement:
            return ("invalid_element", "Element is no longer valid",
                    "The UI may have changed. Re-run get_ui_tree or find_element to get fresh element paths.")
        case .cannotComplete:
            return ("cannot_complete", "The application could not complete the request",
                    "The app may be busy or unresponsive. Check if it is showing a dialog or loading.")
        default:
            return ("accessibility_error", "Accessibility error: \(error)",
                    "Check that the application is running and accessibility permissions are granted.")
        }
    }

    private static func traversalErrorContent(
        _ error: TreeTraversalError,
        operation: String,
        fallbackGuidance: String
    ) -> (errorType: String, message: String, guidance: String) {
        switch error {
        case .timeoutExceeded(let timeout):
            return ("timeout", "\(operation) exceeded \(timeout)s timeout",
                    "Reduce the depth parameter or use find_element with specific criteria.")
        case .invalidDepth(let depth):
            return ("invalid_parameter", "Invalid depth: \(depth)",
                    "Depth must be at least 1. Default is 3.")
        default:
            return ("traversal_error", "\(operation) failed: \(error)", fallbackGuidance)
        }
    }
}
