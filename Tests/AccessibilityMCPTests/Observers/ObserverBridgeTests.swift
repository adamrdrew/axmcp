import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("ObserverBridge Tests")
struct ObserverBridgeTests {

    @Test("Mock bridge creates observer handle")
    func mockCreatesHandle() throws {
        let bridge = MockObserverBridge()
        let handle = try bridge.startObserving(
            pid: 123,
            element: nil,
            notifications: ["AXValueChanged"],
            handler: { _ in }
        )
        #expect(handle.pid == 123)
        #expect(bridge.startCallCount == 1)
    }

    @Test("Mock bridge tracks notifications")
    func mockTracksNotifications() throws {
        let bridge = MockObserverBridge()
        let handle = try bridge.startObserving(
            pid: 123,
            element: nil,
            notifications: ["AXValueChanged", "AXTitleChanged"],
            handler: { _ in }
        )
        let notifs = bridge.notifications(for: handle.id)
        #expect(notifs?.count == 2)
        #expect(notifs?.contains("AXValueChanged") == true)
    }

    @Test("Mock bridge simulates events")
    func mockSimulatesEvents() throws {
        let bridge = MockObserverBridge()
        let collector = EventCollectorBox()
        let handle = try bridge.startObserving(
            pid: 123,
            element: nil,
            notifications: ["AXValueChanged"],
            handler: { event in collector.append(event) }
        )
        let event = ObserverEvent(
            eventType: .valueChanged,
            elementRole: "AXTextField"
        )
        bridge.simulateEvent(handleID: handle.id, event: event)
        #expect(collector.count == 1)
        #expect(collector.events[0].eventType == .valueChanged)
    }

    @Test("Mock bridge stop cleans up")
    func mockStopCleansUp() throws {
        let bridge = MockObserverBridge()
        let handle = try bridge.startObserving(
            pid: 123,
            element: nil,
            notifications: ["AXValueChanged"],
            handler: { _ in }
        )
        #expect(bridge.activeHandleCount() == 1)
        bridge.stopObserving(handle: handle)
        #expect(bridge.activeHandleCount() == 0)
        #expect(bridge.stopCallCount == 1)
    }

    @Test("Mock bridge throws on start when configured")
    func mockThrowsOnStart() {
        let bridge = MockObserverBridge()
        bridge.shouldThrowOnStart = true
        #expect(throws: AccessibilityError.self) {
            try bridge.startObserving(
                pid: 123,
                element: nil,
                notifications: ["AXValueChanged"],
                handler: { _ in }
            )
        }
    }
}

private final class EventCollectorBox: @unchecked Sendable {
    private let lock = NSLock()
    private var _events: [ObserverEvent] = []

    var events: [ObserverEvent] {
        lock.lock()
        defer { lock.unlock() }
        return _events
    }

    var count: Int { events.count }

    func append(_ event: ObserverEvent) {
        lock.lock()
        _events.append(event)
        lock.unlock()
    }
}
