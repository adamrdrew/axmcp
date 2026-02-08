import Foundation
import os

struct OSLogDestination: LogDestination {
    private static let subsystem = "com.adamrdrew.accessibility-mcp"

    func log(
        _ level: LogLevel,
        _ message: String,
        category: String
    ) {
        let logger = os.Logger(
            subsystem: Self.subsystem,
            category: category
        )
        emit(level: level, message: message, logger: logger)
    }

    private func emit(
        level: LogLevel,
        message: String,
        logger: os.Logger
    ) {
        switch level {
        case .debug: logger.debug("\(message, privacy: .public)")
        case .info: logger.info("\(message, privacy: .public)")
        case .warning: logger.warning("\(message, privacy: .public)")
        case .error: logger.error("\(message, privacy: .public)")
        }
    }
}
