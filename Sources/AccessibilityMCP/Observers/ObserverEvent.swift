import Foundation

struct ObserverEvent: Codable, Sendable {
    let timestamp: String
    let eventType: ObserverEventType
    let elementRole: String?
    let elementTitle: String?
    let elementPath: String?
    let newValue: String?

    init(
        eventType: ObserverEventType,
        elementRole: String? = nil,
        elementTitle: String? = nil,
        elementPath: String? = nil,
        newValue: String? = nil
    ) {
        self.timestamp = Self.iso8601Now()
        self.eventType = eventType
        self.elementRole = elementRole
        self.elementTitle = elementTitle
        self.elementPath = elementPath
        self.newValue = newValue
    }

    private static func iso8601Now() -> String {
        ISO8601DateFormatter().string(from: Date())
    }
}
