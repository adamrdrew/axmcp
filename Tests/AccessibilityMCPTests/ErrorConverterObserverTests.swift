import Testing
@testable import AccessibilityMCP

@Suite("ErrorConverter Observer Operations Tests")
struct ErrorConverterObserverTests {

    @Test("Converts invalid application error")
    func convertsInvalidApplication() {
        let error = ObserverError.invalidApplication("bad app")
        let result = ErrorConverter.convertObserverError(
            error, operation: "observe_changes", app: "TestApp"
        )
        if case .toolError(let toolError) = result {
            #expect(toolError.errorType == "invalid_application")
            #expect(toolError.operation == "observe_changes")
            #expect(toolError.app == "TestApp")
        }
    }

    @Test("Converts observer creation failed error")
    func convertsCreationFailed() {
        let error = ObserverError.observerCreationFailed("reason")
        let result = ErrorConverter.convertObserverError(
            error, operation: "observe_changes", app: "Safari"
        )
        if case .toolError(let toolError) = result {
            #expect(toolError.errorType == "observer_creation_failed")
            #expect(toolError.guidance != nil)
        }
    }

    @Test("Converts duration exceeded error")
    func convertsDurationExceeded() {
        let error = ObserverError.durationExceeded(max: 300)
        let result = ErrorConverter.convertObserverError(
            error, operation: "observe_changes", app: "Finder"
        )
        if case .toolError(let toolError) = result {
            #expect(toolError.errorType == "duration_exceeded")
            #expect(toolError.message.contains("300"))
        }
    }

    @Test("Converts application terminated error")
    func convertsAppTerminated() {
        let error = ObserverError.applicationTerminated(pid: 123)
        let result = ErrorConverter.convertObserverError(
            error, operation: "observe_changes", app: "Safari"
        )
        if case .toolError(let toolError) = result {
            #expect(toolError.errorType == "application_terminated")
            #expect(toolError.message.contains("123"))
        }
    }

    @Test("Converts max events exceeded error")
    func convertsMaxEventsExceeded() {
        let error = ObserverError.maxEventsExceeded(limit: 1000)
        let result = ErrorConverter.convertObserverError(
            error, operation: "observe_changes", app: "Xcode"
        )
        if case .toolError(let toolError) = result {
            #expect(toolError.errorType == "max_events_exceeded")
            #expect(toolError.message.contains("1000"))
        }
    }

    @Test("Converts observer already active error")
    func convertsAlreadyActive() {
        let error = ObserverError.observerAlreadyActive(pid: 456)
        let result = ErrorConverter.convertObserverError(
            error, operation: "observe_changes", app: "Safari"
        )
        if case .toolError(let toolError) = result {
            #expect(toolError.errorType == "observer_already_active")
            #expect(toolError.message.contains("456"))
        }
    }
}
