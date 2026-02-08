import Foundation

struct EventCollector: Sendable {
    static let defaultMaxEvents = 1000

    func collect(
        from stream: AsyncStream<ObserverEvent>,
        duration: TimeInterval,
        maxEvents: Int = defaultMaxEvents
    ) async -> EventCollectionResult {
        let start = ContinuousClock.now
        let deadline = Duration.seconds(duration)

        return await withTaskGroup(
            of: EventCollectionResult?.self
        ) { group in
            group.addTask {
                await self.consumeStream(
                    stream, maxEvents: maxEvents, start: start
                )
            }
            group.addTask {
                try? await Task.sleep(for: deadline)
                return nil
            }
            var streamResult: EventCollectionResult?
            for await result in group {
                if let result {
                    streamResult = result
                    group.cancelAll()
                    break
                } else {
                    group.cancelAll()
                    break
                }
            }
            let elapsed = elapsedSeconds(since: start)
            if let r = streamResult { return r }
            return EventCollectionResult(
                events: [], truncated: false,
                earlyTermination: false,
                actualDuration: elapsed
            )
        }
    }

    private func consumeStream(
        _ stream: AsyncStream<ObserverEvent>,
        maxEvents: Int,
        start: ContinuousClock.Instant
    ) async -> EventCollectionResult {
        var events: [ObserverEvent] = []
        var truncated = false
        for await event in stream {
            if Task.isCancelled { break }
            if events.count >= maxEvents {
                truncated = true
                break
            }
            events.append(event)
        }
        let elapsed = elapsedSeconds(since: start)
        let earlyTermination = !truncated && !Task.isCancelled
        return EventCollectionResult(
            events: events, truncated: truncated,
            earlyTermination: earlyTermination,
            actualDuration: elapsed
        )
    }

    private func elapsedSeconds(
        since start: ContinuousClock.Instant
    ) -> TimeInterval {
        let elapsed = start.duration(to: ContinuousClock.now)
        return Double(elapsed.components.seconds)
            + Double(elapsed.components.attoseconds) / 1e18
    }
}
