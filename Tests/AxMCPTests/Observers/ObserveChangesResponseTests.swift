import Testing
import Foundation
@testable import AxMCP

@Suite("ObserveChangesResponse Tests")
struct ObserveChangesResponseTests {

    @Test("Response encodes to valid JSON")
    func encodesToJSON() throws {
        let event = ObserverEvent(
            eventType: .valueChanged,
            elementRole: "AXTextField"
        )
        let response = ObserveChangesResponse(
            events: [event],
            totalEventsCollected: 1,
            eventsReturned: 1,
            truncated: false,
            durationRequested: 30,
            durationActual: 29.5,
            applicationTerminated: false,
            notes: []
        )
        let data = try JSONEncoder().encode(response)
        let decoded = try JSONDecoder().decode(
            ObserveChangesResponse.self,
            from: data
        )
        #expect(decoded.events.count == 1)
        #expect(decoded.truncated == false)
        #expect(decoded.durationRequested == 30)
    }

    @Test("Response with truncation note")
    func responseWithTruncation() throws {
        let response = ObserveChangesResponse(
            events: [],
            totalEventsCollected: 1500,
            eventsReturned: 1000,
            truncated: true,
            durationRequested: 60,
            durationActual: 45.2,
            applicationTerminated: false,
            notes: ["Events truncated at 1000 limit"]
        )
        let data = try JSONEncoder().encode(response)
        let json = String(data: data, encoding: .utf8)!
        #expect(json.contains("truncated"))
        #expect(json.contains("1500"))
    }
}
