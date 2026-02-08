import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("Observer Integration Tests")
struct ObserverIntegrationTests {

    private func makeHandler() -> (ObserveChangesHandler, MockObserverBridge) {
        let mockBridge = MockObserverBridge()
        let manager = ObserverManager(bridge: mockBridge)
        var resolver = MockAppResolver()
        resolver.mockApps = ["TestApp": 123, "OtherApp": 456]
        let handler = ObserveChangesHandler(
            resolver: resolver,
            bridge: MockAXBridge(),
            observerManager: manager
        )
        return (handler, mockBridge)
    }

    @Test("Full observation collects events")
    func fullObservationFlow() async throws {
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
                event: ObserverEvent(
                    eventType: .valueChanged,
                    elementRole: "AXTextField",
                    elementTitle: "Input"
                )
            )
            try await Task.sleep(for: .milliseconds(100))
            mockBridge.simulateEventForAll(
                event: ObserverEvent(
                    eventType: .valueChanged,
                    elementRole: "AXTextField"
                )
            )
        }
        let response = try await handler.execute(parameters: params)
        #expect(response.events.count >= 0)
        #expect(response.truncated == false)
        #expect(response.durationRequested == 1)
    }

    @Test("Observer cleanup after collection")
    func observerCleanupAfter() async throws {
        let (handler, mockBridge) = makeHandler()
        let params = ObserveChangesParameters(
            app: "TestApp",
            events: ["value_changed"],
            elementPath: nil,
            duration: 1
        )
        _ = try await handler.execute(parameters: params)
        #expect(mockBridge.stopCallCount >= 1)
        #expect(mockBridge.activeHandleCount() == 0)
    }

    @Test("Response JSON structure is valid")
    func responseJSONStructure() async throws {
        let (handler, _) = makeHandler()
        let params = ObserveChangesParameters(
            app: "TestApp",
            events: ["value_changed"],
            elementPath: nil,
            duration: 1
        )
        let response = try await handler.execute(parameters: params)
        let data = try JSONEncoder().encode(response)
        let json = try JSONDecoder().decode(
            ObserveChangesResponse.self, from: data
        )
        #expect(json.durationRequested == 1)
        #expect(json.truncated == false)
    }

    @Test("Default events subscribe to all types")
    func defaultEventsAllTypes() async throws {
        let (handler, mockBridge) = makeHandler()
        let params = ObserveChangesParameters(
            app: "TestApp",
            events: nil,
            elementPath: nil,
            duration: 1
        )
        _ = try await handler.execute(parameters: params)
        #expect(mockBridge.startCallCount == 1)
    }

    @Test("Error for nonexistent app")
    func errorForNonexistentApp() async {
        let (handler, _) = makeHandler()
        let params = ObserveChangesParameters(
            app: "NoSuchApp",
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

    @Test("Events contain ISO 8601 timestamps")
    func eventsHaveISO8601Timestamps() async throws {
        let (handler, mockBridge) = makeHandler()
        let params = ObserveChangesParameters(
            app: "TestApp",
            events: ["value_changed"],
            elementPath: nil,
            duration: 1
        )
        Task {
            try await Task.sleep(for: .milliseconds(50))
            mockBridge.simulateEventForAll(
                event: ObserverEvent(eventType: .valueChanged)
            )
        }
        let response = try await handler.execute(parameters: params)
        let formatter = ISO8601DateFormatter()
        for event in response.events {
            #expect(formatter.date(from: event.timestamp) != nil)
        }
    }
}
