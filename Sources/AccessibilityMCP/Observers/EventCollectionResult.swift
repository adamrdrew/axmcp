import Foundation

struct EventCollectionResult: Sendable {
    let events: [ObserverEvent]
    let truncated: Bool
    let earlyTermination: Bool
    let actualDuration: TimeInterval
}
