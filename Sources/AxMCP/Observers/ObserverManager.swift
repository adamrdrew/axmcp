import Foundation

actor ObserverManager {
    private var activeHandles: [UUID: ObserverHandle] = [:]
    private let bridge: any ObserverBridge
    private let maxEvents: Int

    init(bridge: any ObserverBridge, maxEvents: Int = 1000) {
        self.bridge = bridge
        self.maxEvents = maxEvents
    }

    func startObservation(
        pid: pid_t,
        element: UIElement?,
        notifications: [String],
        handler: @escaping @Sendable (ObserverEvent) -> Void
    ) throws(ObserverError) -> UUID {
        do {
            let handle = try bridge.startObserving(
                pid: pid, element: element,
                notifications: notifications,
                handler: handler
            )
            activeHandles[handle.id] = handle
            return handle.id
        } catch {
            throw .observerCreationFailed("\(error)")
        }
    }

    func stopObservation(id: UUID) {
        guard let handle = activeHandles.removeValue(forKey: id) else {
            return
        }
        bridge.stopObserving(handle: handle)
    }

    func stopAll() {
        let handles = activeHandles
        activeHandles.removeAll()
        for handle in handles.values {
            bridge.stopObserving(handle: handle)
        }
    }

    var activeCount: Int { activeHandles.count }
}
