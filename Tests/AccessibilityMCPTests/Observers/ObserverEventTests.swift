import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("ObserverEvent Tests")
struct ObserverEventTests {

    @Test("Event encodes to valid JSON")
    func encodesToJSON() throws {
        let event = ObserverEvent(
            eventType: .valueChanged,
            elementRole: "AXTextField",
            elementTitle: "Search",
            newValue: "hello"
        )
        let data = try JSONEncoder().encode(event)
        let json = try JSONDecoder().decode(
            ObserverEvent.self,
            from: data
        )
        #expect(json.eventType == .valueChanged)
        #expect(json.elementRole == "AXTextField")
        #expect(json.elementTitle == "Search")
        #expect(json.newValue == "hello")
    }

    @Test("Timestamp is ISO 8601 format")
    func timestampIsISO8601() {
        let event = ObserverEvent(eventType: .focusChanged)
        let formatter = ISO8601DateFormatter()
        let parsed = formatter.date(from: event.timestamp)
        #expect(parsed != nil)
    }

    @Test("Optional fields default to nil")
    func optionalFieldsNil() {
        let event = ObserverEvent(eventType: .windowCreated)
        #expect(event.elementRole == nil)
        #expect(event.elementTitle == nil)
        #expect(event.elementPath == nil)
        #expect(event.newValue == nil)
    }

    @Test("Codable round-trip preserves all fields")
    func codableRoundTrip() throws {
        let event = ObserverEvent(
            eventType: .titleChanged,
            elementRole: "AXWindow",
            elementTitle: "Doc",
            elementPath: "app(123)/window[0]",
            newValue: "New Title"
        )
        let data = try JSONEncoder().encode(event)
        let decoded = try JSONDecoder().decode(
            ObserverEvent.self,
            from: data
        )
        #expect(decoded.eventType == .titleChanged)
        #expect(decoded.elementRole == "AXWindow")
        #expect(decoded.elementTitle == "Doc")
        #expect(decoded.elementPath == "app(123)/window[0]")
        #expect(decoded.newValue == "New Title")
    }
}
