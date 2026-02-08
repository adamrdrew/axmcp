import Foundation
import ApplicationServices

final class ObserverContext: @unchecked Sendable {
    private let observer: AXObserver
    private let appElement: AXUIElement
    private let notifications: [String]
    private let handler: @Sendable (ObserverEvent) -> Void
    private let runLoopThread: RunLoopThread
    private let callbackBox: CallbackBox

    init(
        pid: pid_t,
        element: UIElement?,
        notifications: [String],
        handler: @escaping @Sendable (ObserverEvent) -> Void
    ) throws(AccessibilityError) {
        let (box, thread) = Self.createComponents(handler)
        (self.notifications, self.handler) = (notifications, handler)
        (self.appElement, self.observer) = try Self.initialize(pid, element)
        (self.callbackBox, self.runLoopThread) = (box, thread)
        setupAndStart()
    }

    func cleanup() {
        removeNotifications()
        runLoopThread.stopRunLoop(observer: observer)
    }
}

extension ObserverContext {
    private static func createAppElement(
        _ pid: pid_t,
        _ element: UIElement?
    ) -> AXUIElement {
        element?.rawElement ?? AXUIElementCreateApplication(pid)
    }

    private static func createComponents(
        _ handler: @escaping @Sendable (ObserverEvent) -> Void
    ) -> (box: CallbackBox, thread: RunLoopThread) {
        (CallbackBox(handler: handler), RunLoopThread())
    }

    private static func initialize(
        _ pid: pid_t,
        _ element: UIElement?
    ) throws(AccessibilityError) -> (AXUIElement, AXObserver) {
        let app = createAppElement(pid, element)
        let observer = try createObserver(pid: pid)
        return (app, observer)
    }

    private static func createObserver(
        pid: pid_t
    ) throws(AccessibilityError) -> AXObserver {
        var obs: AXObserver?
        try checkObserverCreation(AXObserverCreate(pid, observerCallback, &obs))
        guard let observer = obs else {
            throw AccessibilityError.failure
        }
        return observer
    }

    private static func checkObserverCreation(
        _ err: AXError
    ) throws(AccessibilityError) {
        guard err == .success else {
            throw AccessibilityError.from(code: err)
        }
    }

    private func setupAndStart() {
        let context = Unmanaged.passRetained(callbackBox)
            .toOpaque()
        registerNotifications(context: context)
        runLoopThread.start(observer: observer)
    }

    private func registerNotifications(
        context: UnsafeMutableRawPointer
    ) {
        notifications.forEach { name in
            addNotification(name, context)
        }
    }

    private func addNotification(
        _ name: String,
        _ context: UnsafeMutableRawPointer
    ) {
        AXObserverAddNotification(
            observer, appElement, name as CFString, context
        )
    }

    private func removeNotifications() {
        notifications.forEach { name in
            removeNotification(name)
        }
    }

    private func removeNotification(_ name: String) {
        AXObserverRemoveNotification(
            observer, appElement, name as CFString
        )
    }
}
