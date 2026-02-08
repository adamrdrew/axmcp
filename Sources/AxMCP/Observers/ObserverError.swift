import Foundation

enum ObserverError: Error, Sendable {
    case invalidApplication(String)
    case observerCreationFailed(String)
    case durationExceeded(max: Int)
    case applicationTerminated(pid: pid_t)
    case maxEventsExceeded(limit: Int)
    case observerAlreadyActive(pid: pid_t)
}
