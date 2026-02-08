import Foundation
import ApplicationServices

enum ElementRole: Sendable, Equatable, Hashable {
    case application
    case window
    case button
    case textField
    case staticText
    case checkBox
    case menu
    case menuItem
    case group
    case toolbar
    case list
    case table
    case cell
    case custom(String)

    var rawValue: String {
        switch self {
        case .application: String(kAXApplicationRole)
        case .window: String(kAXWindowRole)
        case .button: String(kAXButtonRole)
        case .textField: String(kAXTextFieldRole)
        case .staticText: String(kAXStaticTextRole)
        case .checkBox: String(kAXCheckBoxRole)
        case .menu: String(kAXMenuRole)
        case .menuItem: String(kAXMenuItemRole)
        case .group: String(kAXGroupRole)
        case .toolbar: String(kAXToolbarRole)
        case .list: String(kAXListRole)
        case .table: String(kAXTableRole)
        case .custom(let name): name
        case .cell: String(kAXCellRole)
        }
    }

    static func from(string: String) -> Self {
        switch string {
        case String(kAXApplicationRole): .application
        case String(kAXWindowRole): .window
        case String(kAXButtonRole): .button
        case String(kAXTextFieldRole): .textField
        case String(kAXStaticTextRole): .staticText
        case String(kAXCheckBoxRole): .checkBox
        case String(kAXMenuRole): .menu
        case String(kAXMenuItemRole): .menuItem
        case String(kAXGroupRole): .group
        case String(kAXToolbarRole): .toolbar
        case String(kAXListRole): .list
        case String(kAXTableRole): .table
        case String(kAXCellRole): .cell
        default: .custom(string)
        }
    }
}
