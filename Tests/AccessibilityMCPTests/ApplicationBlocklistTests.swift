import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("ApplicationBlocklist Tests")
struct ApplicationBlocklistTests {
    @Test("Default blocklist includes standard IDs")
    func testDefaultBlocklist() async {
        let blocklist = ApplicationBlocklist()
        #expect(await blocklist.isBlocked(
            bundleID: "com.apple.keychainaccess"
        ))
        #expect(await blocklist.isBlocked(
            bundleID: "com.apple.Terminal"
        ))
        #expect(await blocklist.isBlocked(
            bundleID: "com.googlecode.iterm2"
        ))
        #expect(await blocklist.isBlocked(
            bundleID: "com.apple.systempreferences"
        ))
    }

    @Test("Non-blocked app passes")
    func testNonBlockedApp() async {
        let blocklist = ApplicationBlocklist()
        let blocked = await blocklist.isBlocked(
            bundleID: "com.example.safe"
        )
        #expect(!blocked)
    }

    @Test("Custom additions to blocklist")
    func testCustomBlocklist() async {
        let blocklist = ApplicationBlocklist(
            additionalBlockedIDs: ["com.example.custom"]
        )
        #expect(await blocklist.isBlocked(
            bundleID: "com.example.custom"
        ))
        #expect(await blocklist.isBlocked(
            bundleID: "com.apple.Terminal"
        ))
    }

    @Test("Bundle ID lookup for app name")
    func testBundleIDLookup() async {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Terminal": 1234]
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .custom("AXBundleIdentifier"): "com.apple.Terminal"
        ]
        let blocklist = ApplicationBlocklist()
        let blocked = await blocklist.isBlocked(
            appName: "Terminal",
            resolver: resolver,
            bridge: bridge
        )
        #expect(blocked)
    }

    @Test("App name not found returns false")
    func testAppNameNotFound() async {
        var resolver = MockAppResolver()
        resolver.shouldThrowNotRunning = true
        let bridge = MockAXBridge()
        let blocklist = ApplicationBlocklist()
        let result = await blocklist.isBlocked(
            appName: "NonExistentApp",
            resolver: resolver,
            bridge: bridge
        )
        #expect(!result)
    }
}
