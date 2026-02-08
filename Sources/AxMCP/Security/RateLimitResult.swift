import Foundation

struct RateLimitResult: Sendable {
    let allowed: Bool
    let delayApplied: TimeInterval?

    var warningMessage: String? {
        guard let delay = delayApplied, delay > 0 else {
            return nil
        }
        return "Rate limit reached. Delayed \(String(format: "%.3f", delay))s"
    }
}
