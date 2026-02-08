import Foundation
import ApplicationServices

enum ElementAttribute: Sendable, Equatable, Hashable {
    case role
    case title
    case description
    case value
    case children
    case parent
    case enabled
    case focused
    case position
    case size
    case identifier
    case roleDescription
    case subrole
    case windows
    case focusedWindow
    case mainWindow
    case custom(String)

    var rawValue: String {
        switch self {
        case .role: String(kAXRoleAttribute)
        case .title: String(kAXTitleAttribute)
        case .description: String(kAXDescriptionAttribute)
        case .value: String(kAXValueAttribute)
        case .children: String(kAXChildrenAttribute)
        case .parent: String(kAXParentAttribute)
        case .enabled: String(kAXEnabledAttribute)
        case .focused: String(kAXFocusedAttribute)
        case .position: String(kAXPositionAttribute)
        case .size: String(kAXSizeAttribute)
        case .identifier: String(kAXIdentifierAttribute)
        case .roleDescription: String(kAXRoleDescriptionAttribute)
        case .subrole: String(kAXSubroleAttribute)
        case .windows: String(kAXWindowsAttribute)
        case .focusedWindow: String(kAXFocusedWindowAttribute)
        case .mainWindow: String(kAXMainWindowAttribute)
        case .custom(let name): name
        }
    }

    static func from(string: String) -> Self {
        switch string {
        case String(kAXRoleAttribute): .role
        case String(kAXTitleAttribute): .title
        case String(kAXDescriptionAttribute): .description
        case String(kAXValueAttribute): .value
        case String(kAXChildrenAttribute): .children
        case String(kAXParentAttribute): .parent
        case String(kAXEnabledAttribute): .enabled
        case String(kAXFocusedAttribute): .focused
        case String(kAXPositionAttribute): .position
        case String(kAXSizeAttribute): .size
        case String(kAXIdentifierAttribute): .identifier
        case String(kAXRoleDescriptionAttribute): .roleDescription
        case String(kAXSubroleAttribute): .subrole
        case String(kAXWindowsAttribute): .windows
        case String(kAXFocusedWindowAttribute): .focusedWindow
        case String(kAXMainWindowAttribute): .mainWindow
        default: .custom(string)
        }
    }
}
