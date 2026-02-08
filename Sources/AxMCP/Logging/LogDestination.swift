import Foundation

protocol LogDestination: Sendable {
    func log(_ level: LogLevel, _ message: String, category: String)
}

enum LogLevel: String, Sendable {
    case debug
    case info
    case warning
    case error
}
