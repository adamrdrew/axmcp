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
                    guidance: "Verify the application name or PID. The app must be running to observe."
                )
            )
        case .observerCreationFailed(let reason):
            return ToolExecutionError.toolError(
                ToolError(
                    operation: operation,
                    errorType: "observer_creation_failed",
                    message: "Failed to create observer: \(reason)",
                    app: app,
                    guidance: "Open System Settings > Privacy & Security > Accessibility and ensure this application has permission."
                )
            )
        case .durationExceeded(let max):
            return ToolExecutionError.toolError(
                ToolError(
                    operation: operation,
                    errorType: "duration_exceeded",
                    message: "Duration exceeds maximum of \(max)s",
                    app: app,
                    guidance: "Set duration to \(max) seconds or less."
                )
            )
        case .applicationTerminated(let pid):
            return ToolExecutionError.toolError(
                ToolError(
                    operation: operation,
                    errorType: "application_terminated",
                    message: "Application (PID \(pid)) terminated during observation",
                    app: app,
                    guidance: "The application quit. Restart it and try again."
                )
            )
        case .maxEventsExceeded(let limit):
            return ToolExecutionError.toolError(
                ToolError(
                    operation: operation,
                    errorType: "max_events_exceeded",
                    message: "Event limit of \(limit) reached",
                    app: app,
                    guidance: "Use a shorter duration or filter to specific event types to reduce volume."
                )
            )
        case .observerAlreadyActive(let pid):
            return ToolExecutionError.toolError(
                ToolError(
                    operation: operation,
                    errorType: "observer_already_active",
                    message: "Observer already active for PID \(pid)",
                    app: app,
                    guidance: "Wait for the current observation to complete before starting another."
                )
            )
        }
    }
}
