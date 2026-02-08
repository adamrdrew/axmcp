import Foundation
@testable import AxMCP

final class MockLogDestination: LogDestination, @unchecked Sendable {
    private let lock = NSLock()
    private var _entries: [LogEntry] = []

    var entries: [LogEntry] {
        lock.lock()
        defer { lock.unlock() }
        return _entries
    }

    func log(
        _ level: LogLevel,
        _ message: String,
        category: String
    ) {
        lock.lock()
        defer { lock.unlock() }
        _entries.append(
            LogEntry(level: level, message: message, category: category)
        )
    }

    func clear() {
        lock.lock()
        defer { lock.unlock() }
        _entries.removeAll()
    }
}

struct LogEntry: Sendable {
    let level: LogLevel
    let message: String
    let category: String
}
