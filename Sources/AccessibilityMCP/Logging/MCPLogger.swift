import Foundation

struct MCPLogger: Sendable {
    let destination: any LogDestination
    let category: LogCategory

    func debug(_ message: String) {
        destination.log(.debug, message, category: category.rawValue)
    }

    func info(_ message: String) {
        destination.log(.info, message, category: category.rawValue)
    }

    func warning(_ message: String) {
        destination.log(.warning, message, category: category.rawValue)
    }

    func error(_ message: String) {
        destination.log(.error, message, category: category.rawValue)
    }
}
