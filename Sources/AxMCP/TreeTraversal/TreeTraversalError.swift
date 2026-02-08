import Foundation

enum TreeTraversalError: Error, Sendable {
    case invalidDepth(Int)
    case timeoutExceeded(TimeInterval)
    case accessibilityError(AccessibilityError)
    case invalidElement
}
