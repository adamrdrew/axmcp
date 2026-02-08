import Foundation
import ApplicationServices

final class CallbackBox: @unchecked Sendable {
    let handler: @Sendable (ObserverEvent) -> Void

    init(handler: @escaping @Sendable (ObserverEvent) -> Void) {
        self.handler = handler
    }
}

func observerCallback(
    _ observer: AXObserver,
    _ element: AXUIElement,
    _ notification: CFString,
    _ userData: UnsafeMutableRawPointer?
) {
    guard let box = extractCallbackBox(from: userData),
          let event = createEvent(from: element, notification) else {
        return
    }
    box.handler(event)
}

private func extractCallbackBox(
    from userData: UnsafeMutableRawPointer?
) -> CallbackBox? {
    guard let userData else { return nil }
    return Unmanaged<CallbackBox>.fromOpaque(userData)
        .takeUnretainedValue()
}

private func createEvent(
    from element: AXUIElement,
    _ notification: CFString
) -> ObserverEvent? {
    let name = notification as String
    guard let eventType = ObserverEventType(from: name) else {
        return nil
    }
    return buildEvent(eventType, element)
}

private func buildEvent(
    _ eventType: ObserverEventType,
    _ element: AXUIElement
) -> ObserverEvent {
    let (role, title) = extractAttributes(element)
    return ObserverEvent(eventType: eventType, elementRole: role, elementTitle: title)
}

private func extractAttributes(
    _ element: AXUIElement
) -> (String?, String?) {
    let role = extractAttribute(element, kAXRoleAttribute)
    let title = extractAttribute(element, kAXTitleAttribute)
    return (role, title)
}

private func extractAttribute(
    _ element: AXUIElement,
    _ attribute: String
) -> String? {
    var value: CFTypeRef?
    let err = copyAttributeValue(element, attribute, &value)
    guard err == .success, let v = value else { return nil }
    return v as? String
}

private func copyAttributeValue(
    _ element: AXUIElement,
    _ attribute: String,
    _ value: inout CFTypeRef?
) -> AXError {
    AXUIElementCopyAttributeValue(
        element, attribute as CFString, &value
    )
}
