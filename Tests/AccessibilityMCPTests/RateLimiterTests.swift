import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("RateLimiter Tests")
struct RateLimiterTests {
    @Test("Within limit allows action")
    func testWithinLimit() async {
        let limiter = RateLimiter(maxActionsPerSecond: 10)
        let result = await limiter.checkAndRecord()
        #expect(result.allowed)
        #expect(result.delayApplied == nil)
    }

    @Test("Multiple actions within limit pass")
    func testMultipleActionsWithinLimit() async {
        let limiter = RateLimiter(maxActionsPerSecond: 5)
        for _ in 0..<5 {
            let result = await limiter.checkAndRecord()
            #expect(result.allowed)
        }
    }

    @Test("Burst beyond limit applies delay")
    func testBurstDelay() async {
        let limiter = RateLimiter(maxActionsPerSecond: 2)
        let result1 = await limiter.checkAndRecord()
        let result2 = await limiter.checkAndRecord()
        let result3 = await limiter.checkAndRecord()
        #expect(result1.delayApplied == nil)
        #expect(result2.delayApplied == nil)
        #expect(result3.delayApplied != nil)
    }

    @Test("Timestamps are pruned after one second")
    func testTimestampPruning() async {
        let limiter = RateLimiter(maxActionsPerSecond: 2)
        _ = await limiter.checkAndRecord()
        _ = await limiter.checkAndRecord()
        try? await Task.sleep(nanoseconds: 1_100_000_000)
        let result = await limiter.checkAndRecord()
        #expect(result.delayApplied == nil)
    }

    @Test("Warning message includes delay")
    func testWarningMessage() {
        let result = RateLimitResult(
            allowed: true,
            delayApplied: 0.123
        )
        #expect(result.warningMessage != nil)
        #expect(result.warningMessage?.contains("0.123") == true)
    }

    @Test("No warning when no delay")
    func testNoWarning() {
        let result = RateLimitResult(
            allowed: true,
            delayApplied: nil
        )
        #expect(result.warningMessage == nil)
    }
}
