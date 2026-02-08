import Foundation

protocol ObserverBridge: Sendable {
    func startObserving(
        pid: pid_t,
        element: UIElement?,
        notifications: [String],
        handler: @escaping @Sendable (ObserverEvent) -> Void
    ) throws(AccessibilityError) -> ObserverHandle

    func stopObserving(handle: ObserverHandle)
}

struct ObserverHandle: Sendable {
    let id: UUID
    let pid: pid_t

    init(pid: pid_t) {
        self.id = UUID()
        self.pid = pid
    }
}
