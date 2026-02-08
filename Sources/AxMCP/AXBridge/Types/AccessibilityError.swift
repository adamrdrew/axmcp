import Foundation
import ApplicationServices

enum AccessibilityError: Error, Sendable {
    case success
    case failure
    case invalidUIElement
    case cannotComplete
    case attributeUnsupported
    case actionUnsupported
    case notificationUnsupported
    case notImplemented
    case notificationAlreadyRegistered
    case notificationNotRegistered
    case apiDisabled
    case noValue
    case parameterizedAttributeUnsupported
    case notEnoughPrecision
    case permissionDenied(guidance: String)
    case typeMismatch(expected: String, actual: String)
    case attributeNotFound(String)

    static func from(code: AXError) -> Self {
        switch code {
        case .success: .success
        case .failure: .failure
        case .invalidUIElement: .invalidUIElement
        case .invalidUIElementObserver: .invalidUIElement
        case .cannotComplete: .cannotComplete
        case .attributeUnsupported: .attributeUnsupported
        case .actionUnsupported: .actionUnsupported
        case .notificationUnsupported: .notificationUnsupported
        case .notImplemented: .notImplemented
        case .notificationAlreadyRegistered: .notificationAlreadyRegistered
        case .notificationNotRegistered: .notificationNotRegistered
        case .apiDisabled: .apiDisabled
        case .noValue: .noValue
        case .parameterizedAttributeUnsupported: .parameterizedAttributeUnsupported
        case .notEnoughPrecision: .notEnoughPrecision
        case .illegalArgument: .failure
        @unknown default: .failure
        }
    }
}
