import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("ServerConfiguration Tests")
struct ServerConfigurationTests {
    @Test("Default configuration")
    func testDefaultConfiguration() {
        let config = ServerConfiguration()
        #expect(config.readOnlyMode == false)
        #expect(config.rateLimitPerSecond == 10)
        #expect(config.blockedBundleIDs.isEmpty)
    }

    @Test("Custom configuration")
    func testCustomConfiguration() {
        let config = ServerConfiguration(
            readOnlyMode: true,
            rateLimitPerSecond: 5,
            blockedBundleIDs: ["com.example.test"]
        )
        #expect(config.readOnlyMode == true)
        #expect(config.rateLimitPerSecond == 5)
        #expect(config.blockedBundleIDs == ["com.example.test"])
    }
}
