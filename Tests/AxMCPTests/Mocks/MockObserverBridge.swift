import Foundation
@testable import AxMCP

final class MockObserverBridge: ObserverBridge, @unchecked Sendable {
    private let lock = NSLock()
    private var handlers: [UUID: @Sendable (ObserverEvent) -> Void] = [:]
    private var registeredNotifications: [UUID: [String]] = [:]
    var shouldThrowOnStart = false
    var startCallCount = 0
    var stopCallCount = 0

    func startObserving(
        pid: pid_t,
        element: UIElement?,
        notifications: [String],
        handler: @escaping @Sendable (ObserverEvent) -> Void
    ) throws(AccessibilityError) -> ObserverHandle {
        lock.lock()
        startCallCount += 1
        lock.unlock()
        if shouldThrowOnStart {
            throw AccessibilityError.failure
        }
        let handle = ObserverHandle(pid: pid)
        lock.lock()
        handlers[handle.id] = handler
        registeredNotifications[handle.id] = notifications
        lock.unlock()
        return handle
    }

    func stopObserving(handle: ObserverHandle) {
        lock.lock()
        stopCallCount += 1
        handlers.removeValue(forKey: handle.id)
        registeredNotifications.removeValue(forKey: handle.id)
        lock.unlock()
    }

    func simulateEvent(
        handleID: UUID,
        event: ObserverEvent
    ) {
        lock.lock()
        let handler = handlers[handleID]
        lock.unlock()
        handler?(event)
    }

    func simulateEventForAll(event: ObserverEvent) {
        lock.lock()
        let allHandlers = Array(handlers.values)
        lock.unlock()
        for handler in allHandlers {
            handler(event)
        }
    }

    func activeHandleCount() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return handlers.count
    }

    func notifications(for id: UUID) -> [String]? {
        lock.lock()
        defer { lock.unlock() }
        return registeredNotifications[id]
    }
}
