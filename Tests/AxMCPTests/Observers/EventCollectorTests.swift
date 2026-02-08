import Testing
import Foundation
@testable import AxMCP

@Suite("EventCollector Tests")
struct EventCollectorTests {

    @Test("Collects events within duration")
    func collectsWithinDuration() async {
        let stream = AsyncStream<ObserverEvent> { cont in
            cont.yield(ObserverEvent(eventType: .valueChanged))
            cont.yield(ObserverEvent(eventType: .focusChanged))
            cont.finish()
        }
        let collector = EventCollector()
        let result = await collector.collect(
            from: stream, duration: 5.0
        )
        #expect(result.events.count == 2)
        #expect(result.truncated == false)
    }

    @Test("Truncates at max events")
    func truncatesAtMaxEvents() async {
        let stream = AsyncStream<ObserverEvent> { cont in
            for _ in 0..<10 {
                cont.yield(ObserverEvent(eventType: .valueChanged))
            }
            cont.finish()
        }
        let collector = EventCollector()
        let result = await collector.collect(
            from: stream, duration: 5.0, maxEvents: 3
        )
        #expect(result.events.count == 3)
        #expect(result.truncated == true)
    }

    @Test("Handles empty stream (early termination)")
    func handlesEmptyStream() async {
        let stream = AsyncStream<ObserverEvent> { cont in
            cont.finish()
        }
        let collector = EventCollector()
        let result = await collector.collect(
            from: stream, duration: 1.0
        )
        #expect(result.events.isEmpty)
        #expect(result.earlyTermination == true)
    }

    @Test("Early termination when stream ends before duration")
    func earlyTerminationOnStreamEnd() async {
        let stream = AsyncStream<ObserverEvent> { cont in
            cont.yield(ObserverEvent(eventType: .titleChanged))
            cont.finish()
        }
        let collector = EventCollector()
        let result = await collector.collect(
            from: stream, duration: 60.0
        )
        #expect(result.events.count == 1)
        #expect(result.earlyTermination == true)
        #expect(result.actualDuration < 5.0)
    }

    @Test("Duration is tracked")
    func durationTracked() async {
        let stream = AsyncStream<ObserverEvent> { cont in
            cont.finish()
        }
        let collector = EventCollector()
        let result = await collector.collect(
            from: stream, duration: 1.0
        )
        #expect(result.actualDuration >= 0)
    }
}
