import Foundation

actor RateLimiter {
    private var timestamps: [TimeInterval] = []
    private let maxActionsPerSecond: Int

    init(maxActionsPerSecond: Int) {
        self.maxActionsPerSecond = maxActionsPerSecond
    }

    func checkAndRecord() async -> RateLimitResult {
        let now = getCurrentTime()
        pruneOldTimestamps(now: now)
        let delay = calculateDelay(now: now)
        if let delay = delay, delay > 0 {
            await sleep(for: delay)
        }
        timestamps.append(now + (delay ?? 0))
        return RateLimitResult(
            allowed: true,
            delayApplied: delay
        )
    }

    private func getCurrentTime() -> TimeInterval {
        Date().timeIntervalSince1970
    }

    private func pruneOldTimestamps(now: TimeInterval) {
        timestamps.removeAll { now - $0 > 1.0 }
    }

    private func calculateDelay(now: TimeInterval) -> TimeInterval? {
        guard timestamps.count >= maxActionsPerSecond else {
            return nil
        }
        guard let oldest = timestamps.first else {
            return nil
        }
        return max(0, oldest + 1.0 - now)
    }

    private func sleep(for duration: TimeInterval) async {
        try? await Task.sleep(
            nanoseconds: UInt64(duration * 1_000_000_000)
        )
    }
}
