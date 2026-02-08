import Testing
import Foundation
@testable import AxMCP

@Suite("ObserveChangesHandler Tests")
struct ObserveChangesHandlerTests {

    private func makeHandler() -> (ObserveChangesHandler, MockObserverBridge) {
        let mockBridge = MockObserverBridge()
        let manager = ObserverManager(bridge: mockBridge)
        var resolver = MockAppResolver()
        resolver.mockApps = ["TestApp": 123]
        let handler = ObserveChangesHandler(
            resolver: resolver,
            bridge: MockAXBridge(),
            observerManager: manager
        )
        return (handler, mockBridge)
    }

    @Test("Executes observation and returns response")
    func executesObservation() async throws {
        let (handler, mockBridge) = makeHandler()
        let params = ObserveChangesParameters(
            app: "TestApp",
            events: ["value_changed"],
            elementPath: nil,
            duration: 1
        )
        Task {
            try await Task.sleep(for: .milliseconds(100))
            mockBridge.simulateEventForAll(
                event: ObserverEvent(eventType: .valueChanged)
            )
        }
        let response = try await handler.execute(parameters: params)
        #expect(response.durationRequested == 1)
    }

    @Test("Empty app throws parameter error")
    func emptyAppThrowsError() async {
        let (handler, _) = makeHandler()
        let params = ObserveChangesParameters(
            app: "",
            events: nil,
            elementPath: nil,
            duration: 1
        )
        do {
            _ = try await handler.execute(parameters: params)
            Issue.record("Expected error for empty app")
        } catch {
            #expect(error is ToolExecutionError)
        }
    }

    @Test("Invalid event type throws parameter error")
    func invalidEventTypeThrows() async {
        let (handler, _) = makeHandler()
        let params = ObserveChangesParameters(
            app: "TestApp",
            events: ["nonexistent_event"],
            elementPath: nil,
            duration: 1
        )
        do {
            _ = try await handler.execute(parameters: params)
            Issue.record("Expected error for invalid event")
        } catch {
            #expect(error is ToolExecutionError)
        }
    }

    @Test("Duration clamping noted in response")
    func durationClampingNoted() {
        let params = ObserveChangesParameters(
            app: "TestApp",
            events: ["value_changed"],
            elementPath: nil,
            duration: 500
        )
        #expect(params.effectiveDuration == 300)
        #expect(params.durationWasClamped == true)
    }

    @Test("Empty observation returns empty events")
    func emptyObservation() async throws {
        let (handler, _) = makeHandler()
        let params = ObserveChangesParameters(
            app: "TestApp",
            events: ["value_changed"],
            elementPath: nil,
            duration: 1
        )
        let response = try await handler.execute(parameters: params)
        #expect(response.truncated == false)
    }

    @Test("App not running throws error")
    func appNotRunningThrows() async {
        let (handler, _) = makeHandler()
        let params = ObserveChangesParameters(
            app: "NonexistentApp",
            events: nil,
            elementPath: nil,
            duration: 1
        )
        do {
            _ = try await handler.execute(parameters: params)
            Issue.record("Expected error for nonexistent app")
        } catch {
            #expect(error is ToolExecutionError)
        }
    }
}
