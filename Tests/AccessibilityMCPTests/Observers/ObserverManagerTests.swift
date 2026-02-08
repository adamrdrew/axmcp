import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("ObserverManager Tests")
struct ObserverManagerTests {

    @Test("Starts observation and tracks handle")
    func startsAndTracks() async throws {
        let bridge = MockObserverBridge()
        let manager = ObserverManager(bridge: bridge)
        let id = try await manager.startObservation(
            pid: 123,
            element: nil,
            notifications: ["AXValueChanged"],
            handler: { _ in }
        )
        let count = await manager.activeCount
        #expect(count == 1)
        #expect(bridge.startCallCount == 1)
        _ = id
    }

    @Test("Stops observation and cleans up")
    func stopsAndCleansUp() async throws {
        let bridge = MockObserverBridge()
        let manager = ObserverManager(bridge: bridge)
        let id = try await manager.startObservation(
            pid: 123,
            element: nil,
            notifications: ["AXValueChanged"],
            handler: { _ in }
        )
        await manager.stopObservation(id: id)
        let count = await manager.activeCount
        #expect(count == 0)
        #expect(bridge.stopCallCount == 1)
    }

    @Test("StopAll cleans up all observers")
    func stopAllCleansUp() async throws {
        let bridge = MockObserverBridge()
        let manager = ObserverManager(bridge: bridge)
        _ = try await manager.startObservation(
            pid: 123,
            element: nil,
            notifications: ["AXValueChanged"],
            handler: { _ in }
        )
        _ = try await manager.startObservation(
            pid: 456,
            element: nil,
            notifications: ["AXTitleChanged"],
            handler: { _ in }
        )
        let before = await manager.activeCount
        #expect(before == 2)
        await manager.stopAll()
        let after = await manager.activeCount
        #expect(after == 0)
        #expect(bridge.stopCallCount == 2)
    }

    @Test("Stop nonexistent ID is no-op")
    func stopNonexistentIsNoOp() async {
        let bridge = MockObserverBridge()
        let manager = ObserverManager(bridge: bridge)
        await manager.stopObservation(id: UUID())
        #expect(bridge.stopCallCount == 0)
    }

    @Test("Throws on observer creation failure")
    func throwsOnCreationFailure() async {
        let bridge = MockObserverBridge()
        bridge.shouldThrowOnStart = true
        let manager = ObserverManager(bridge: bridge)
        do {
            _ = try await manager.startObservation(
                pid: 123,
                element: nil,
                notifications: ["AXValueChanged"],
                handler: { _ in }
            )
            Issue.record("Expected ObserverError")
        } catch {
            #expect(error is ObserverError)
        }
    }
}
