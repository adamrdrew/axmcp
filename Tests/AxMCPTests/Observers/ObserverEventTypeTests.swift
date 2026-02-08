import Testing
@testable import AxMCP

@Suite("ObserverEventType Tests")
struct ObserverEventTypeTests {

    @Test("Maps AX notification names to event types")
    func mapsFromAXNotifications() {
        #expect(ObserverEventType(from: "AXValueChanged") == .valueChanged)
        #expect(ObserverEventType(from: "AXFocusedUIElementChanged") == .focusChanged)
        #expect(ObserverEventType(from: "AXWindowCreated") == .windowCreated)
        #expect(ObserverEventType(from: "AXUIElementDestroyed") == .windowDestroyed)
        #expect(ObserverEventType(from: "AXTitleChanged") == .titleChanged)
    }

    @Test("Returns nil for unknown AX notification")
    func returnsNilForUnknown() {
        #expect(ObserverEventType(from: "AXUnknown") == nil)
    }

    @Test("Maps event types back to AX notification names")
    func mapsToAXNotifications() {
        #expect(ObserverEventType.valueChanged.axNotificationName == "AXValueChanged")
        #expect(ObserverEventType.focusChanged.axNotificationName == "AXFocusedUIElementChanged")
        #expect(ObserverEventType.windowCreated.axNotificationName == "AXWindowCreated")
        #expect(ObserverEventType.windowDestroyed.axNotificationName == "AXUIElementDestroyed")
        #expect(ObserverEventType.titleChanged.axNotificationName == "AXTitleChanged")
    }

    @Test("Bidirectional mapping is consistent")
    func bidirectionalMapping() {
        let types: [ObserverEventType] = [
            .valueChanged, .focusChanged,
            .windowCreated, .windowDestroyed, .titleChanged
        ]
        for eventType in types {
            let name = eventType.axNotificationName
            let roundTripped = ObserverEventType(from: name)
            #expect(roundTripped == eventType)
        }
    }

    @Test("Raw values use snake_case for JSON")
    func rawValuesAreSnakeCase() {
        #expect(ObserverEventType.valueChanged.rawValue == "value_changed")
        #expect(ObserverEventType.focusChanged.rawValue == "focus_changed")
        #expect(ObserverEventType.windowCreated.rawValue == "window_created")
        #expect(ObserverEventType.windowDestroyed.rawValue == "window_destroyed")
        #expect(ObserverEventType.titleChanged.rawValue == "title_changed")
    }
}
