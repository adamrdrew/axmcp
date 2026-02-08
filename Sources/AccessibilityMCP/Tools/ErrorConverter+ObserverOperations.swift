import Foundation

extension ErrorConverter {
    static func convertObserverError(
        _ error: ObserverError,
        operation: String,
        app: String
    ) -> ToolExecutionError {
        switch error {
        case .invalidApplication(let reason):
            return ToolExecutionError.toolError(
                ToolError(
                    operation: operation,
                    errorType: "invalid_application",
                    message: "Invalid application: \(reason)",
                    app: app,
                    guidance: "Check the application name or PID"
                )
            )
        case .observerCreationFailed(let reason):
            return ToolExecutionError.toolError(
                ToolError(
                    operation: operation,
                    errorType: "observer_creation_failed",
                    message: "Failed to create observer: \(reason)",
                    app: app,
                    guidance: "Ensure accessibility permissions are granted"
                )
            )
        case .durationExceeded(let max):
            return ToolExecutionError.toolError(
                ToolError(
                    operation: operation,
                    errorType: "duration_exceeded",
                    message: "Duration exceeds maximum of \(max)s",
                    app: app
                )
            )
        case .applicationTerminated(let pid):
            return ToolExecutionError.toolError(
                ToolError(
                    operation: operation,
                    errorType: "application_terminated",
                    message: "Application (PID \(pid)) terminated",
                    app: app,
                    guidance: "Application quit during observation"
                )
            )
        case .maxEventsExceeded(let limit):
            return ToolExecutionError.toolError(
                ToolError(
                    operation: operation,
                    errorType: "max_events_exceeded",
                    message: "Event limit of \(limit) reached",
                    app: app
                )
            )
        case .observerAlreadyActive(let pid):
            return ToolExecutionError.toolError(
                ToolError(
                    operation: operation,
                    errorType: "observer_already_active",
                    message: "Observer already active for PID \(pid)",
                    app: app
                )
            )
        }
    }
}
