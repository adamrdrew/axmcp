import Foundation

struct ObserveChangesResponse: Codable, Sendable {
    let events: [ObserverEvent]
    let totalEventsCollected: Int
    let eventsReturned: Int
    let truncated: Bool
    let durationRequested: Int
    let durationActual: Double
    let applicationTerminated: Bool
    let notes: [String]
}
