import Foundation

enum ElementPathError: Error, Sendable, Equatable {
    case invalidFormat(String)
    case emptyPath
    case pathTooLong(Int)
    case invalidPID(pid_t)
    case componentNotFound(ElementPathComponent, available: [String])
    case elementNotFound(ElementPath)
    case staleReference(ElementPath)
    case timeoutExceeded(TimeInterval)
    case accessibilityError(AccessibilityError)

    static func == (lhs: ElementPathError, rhs: ElementPathError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidFormat(let a), .invalidFormat(let b)):
            return a == b
        case (.emptyPath, .emptyPath):
            return true
        case (.pathTooLong(let a), .pathTooLong(let b)):
            return a == b
        case (.invalidPID(let a), .invalidPID(let b)):
            return a == b
        case (.componentNotFound(let a, let c), .componentNotFound(let b, let d)):
            return a == b && c == d
        case (.elementNotFound(let a), .elementNotFound(let b)):
            return a == b
        case (.staleReference(let a), .staleReference(let b)):
            return a == b
        case (.timeoutExceeded(let a), .timeoutExceeded(let b)):
            return a == b
        case (.accessibilityError, .accessibilityError):
            return true
        default:
            return false
        }
    }
}
