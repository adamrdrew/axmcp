import Foundation

struct ObserveChangesParameters: Codable, Sendable {
    let app: String
    let events: [String]?
    let elementPath: String?
    let duration: Int?

    static let defaultDuration = 30
    static let maxDuration = 300
    static let minDuration = 1

    var effectiveDuration: Int {
        let raw = duration ?? Self.defaultDuration
        return min(max(raw, Self.minDuration), Self.maxDuration)
    }

    var durationWasClamped: Bool {
        guard let d = duration else { return false }
        return d > Self.maxDuration || d < Self.minDuration
    }

    func validate() throws(ToolParameterError) {
        try validateApp()
        try validateEvents()
    }

    private func validateApp() throws(ToolParameterError) {
        guard !app.isEmpty else {
            throw .missingRequired(parameter: "app")
        }
    }

    private func validateEvents() throws(ToolParameterError) {
        guard let events else { return }
        for event in events {
            guard ObserverEventType(rawValue: event) != nil else {
                throw .invalidValue(
                    parameter: "events",
                    value: event,
                    reason: "Unknown event type. Valid: \(ObserverEventType.allEventNames.joined(separator: ", "))"
                )
            }
        }
    }
}
