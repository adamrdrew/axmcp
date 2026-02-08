import Foundation
import ApplicationServices

enum ElementAction: Sendable, Equatable {
    case press
    case pick
    case showMenu
    case confirm
    case cancel
    case raise
    case increment
    case decrement
    case custom(String)

    var rawValue: String {
        switch self {
        case .press: String(kAXPressAction)
        case .pick: String(kAXPickAction)
        case .showMenu: String(kAXShowMenuAction)
        case .confirm: String(kAXConfirmAction)
        case .cancel: String(kAXCancelAction)
        case .raise: String(kAXRaiseAction)
        case .increment: String(kAXIncrementAction)
        case .decrement: String(kAXDecrementAction)
        case .custom(let name): name
        }
    }

    static func from(string: String) -> Self {
        switch string {
        case String(kAXPressAction): .press
        case String(kAXPickAction): .pick
        case String(kAXShowMenuAction): .showMenu
        case String(kAXConfirmAction): .confirm
        case String(kAXCancelAction): .cancel
        case String(kAXRaiseAction): .raise
        case String(kAXIncrementAction): .increment
        case String(kAXDecrementAction): .decrement
        default: .custom(string)
        }
    }
}
