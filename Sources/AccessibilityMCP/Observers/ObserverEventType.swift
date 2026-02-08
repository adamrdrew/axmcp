import Foundation

enum ObserverEventType: String, Codable, Sendable {
    case valueChanged = "value_changed"
    case focusChanged = "focus_changed"
    case windowCreated = "window_created"
    case windowDestroyed = "window_destroyed"
    case titleChanged = "title_changed"

    init?(from axNotification: String) {
        switch axNotification {
        case "AXValueChanged": self = .valueChanged
        case "AXFocusedUIElementChanged": self = .focusChanged
        case "AXWindowCreated": self = .windowCreated
        case "AXUIElementDestroyed": self = .windowDestroyed
        case "AXTitleChanged": self = .titleChanged
        default: return nil
        }
    }

    var axNotificationName: String {
        switch self {
        case .valueChanged: "AXValueChanged"
        case .focusChanged: "AXFocusedUIElementChanged"
        case .windowCreated: "AXWindowCreated"
        case .windowDestroyed: "AXUIElementDestroyed"
        case .titleChanged: "AXTitleChanged"
        }
    }

    static let allEventNames: [String] = {
        let types: [ObserverEventType] = [
            .valueChanged, .focusChanged,
            .windowCreated, .windowDestroyed, .titleChanged
        ]
        return types.map(\.rawValue)
    }()
}
