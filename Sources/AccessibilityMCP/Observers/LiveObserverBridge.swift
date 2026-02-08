import Foundation
import ApplicationServices

final class LiveObserverBridge: ObserverBridge, @unchecked Sendable {
    private let lock = NSLock()
    private var activeContexts: [UUID: ObserverContext] = [:]

    func startObserving(
        pid: pid_t,
        element: UIElement?,
        notifications: [String],
        handler: @escaping @Sendable (ObserverEvent) -> Void
    ) throws(AccessibilityError) -> ObserverHandle {
        let handle = ObserverHandle(pid: pid)
        let context = try createContext(
            pid: pid, element: element,
            notifications: notifications,
            handler: handler, handle: handle
        )
        storeContext(context, for: handle.id)
        return handle
    }

    func stopObserving(handle: ObserverHandle) {
        guard let context = removeContext(for: handle.id) else {
            return
        }
        context.cleanup()
    }
}

extension LiveObserverBridge {
    private func createContext(
        pid: pid_t,
        element: UIElement?,
        notifications: [String],
        handler: @escaping @Sendable (ObserverEvent) -> Void,
        handle: ObserverHandle
    ) throws(AccessibilityError) -> ObserverContext {
        try ObserverContext(
            pid: pid, element: element,
            notifications: notifications,
            handler: handler
        )
    }

    private func storeContext(
        _ context: ObserverContext,
        for id: UUID
    ) {
        lock.lock()
        activeContexts[id] = context
        lock.unlock()
    }

    private func removeContext(for id: UUID) -> ObserverContext? {
        lock.lock()
        defer { lock.unlock() }
        return activeContexts.removeValue(forKey: id)
    }
}
