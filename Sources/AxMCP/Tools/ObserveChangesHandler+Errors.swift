import Foundation

extension ObserveChangesHandler {
    func convertParameterError(
        _ error: ToolParameterError,
        _ params: ObserveChangesParameters
    ) -> ToolExecutionError {
        ErrorConverter.convertParameterError(
            error, operation: "observe_changes"
        )
    }

    func convertAppError(
        _ error: AppResolutionError,
        _ params: ObserveChangesParameters
    ) -> ToolExecutionError {
        ErrorConverter.convertAppError(
            error, operation: "observe_changes"
        )
    }

    func convertPathError(
        _ error: ElementPathError,
        _ params: ObserveChangesParameters
    ) -> ToolExecutionError {
        ErrorConverter.convertElementPathError(
            error, operation: "observe_changes",
            app: params.app
        )
    }

    func convertObserverError(
        _ error: ObserverError,
        _ params: ObserveChangesParameters
    ) -> ToolExecutionError {
        ErrorConverter.convertObserverError(
            error, operation: "observe_changes",
            app: params.app
        )
    }

    func createUnknownError(
        _ error: any Error,
        _ params: ObserveChangesParameters
    ) -> ToolExecutionError {
        ToolExecutionError.toolError(
            ToolError(
                operation: "observe_changes",
                errorType: "unknown_error",
                message: "Unexpected error: \(error)",
                app: params.app
            )
        )
    }

    func startStream(
        pid: pid_t,
        element: UIElement?,
        notifications: [String]
    ) async throws(ObserverError) -> (AsyncStream<ObserverEvent>, AsyncStream<ObserverEvent>.Continuation, UUID) {
        let (stream, continuation) = AsyncStream.makeStream(
            of: ObserverEvent.self
        )
        let handler: @Sendable (ObserverEvent) -> Void = {
            event in continuation.yield(event)
        }
        let id = try await observerManager.startObservation(
            pid: pid, element: element,
            notifications: notifications,
            handler: handler
        )
        return (stream, continuation, id)
    }

    func buildResponse(
        _ result: EventCollectionResult,
        _ parameters: ObserveChangesParameters
    ) -> ObserveChangesResponse {
        var notes: [String] = []
        if result.truncated {
            notes.append(
                "Events truncated at \(EventCollector.defaultMaxEvents) limit"
            )
        }
        if parameters.durationWasClamped {
            notes.append(
                "Duration clamped to \(ObserveChangesParameters.maxDuration)s"
            )
        }
        return ObserveChangesResponse(
            events: result.events,
            totalEventsCollected: result.events.count,
            eventsReturned: result.events.count,
            truncated: result.truncated,
            durationRequested: parameters.effectiveDuration,
            durationActual: result.actualDuration,
            applicationTerminated: result.earlyTermination,
            notes: notes
        )
    }
}
