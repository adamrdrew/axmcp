import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("SetValueHandler Tests")
struct SetValueHandlerTests {
    func createHandler(
        config: ServerConfiguration = ServerConfiguration(),
        bridge: MockAXBridge = MockAXBridge(),
        resolver: MockAppResolver = MockAppResolver()
    ) -> (SetValueHandler, ApplicationBlocklist, RateLimiter) {
        let blocklist = ApplicationBlocklist(
            additionalBlockedIDs: config.blockedBundleIDs
        )
        let rateLimiter = RateLimiter(
            maxActionsPerSecond: config.rateLimitPerSecond
        )
        let handler = SetValueHandler(
            resolver: resolver,
            bridge: bridge,
            blocklist: blocklist,
            rateLimiter: rateLimiter,
            config: config
        )
        return (handler, blocklist, rateLimiter)
    }

    @Test("Sets string value and returns state")
    func testSetStringValue() async throws {
        var resolver = MockAppResolver()
        resolver.mockApps = ["TextEdit": 1234]
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .role: "AXTextField",
            .value: "old value",
            .enabled: true
        ]
        let (handler, _, _) = createHandler(
            bridge: bridge,
            resolver: resolver
        )
        let params = SetValueParameters(
            app: "TextEdit",
            elementPath: "app(1234)",
            value: .string("new value")
        )
        let response = try await handler.execute(parameters: params)
        #expect(response.success == true)
        #expect(response.previousValue == "old value")
    }

    @Test("Sets boolean value")
    func testSetBooleanValue() async throws {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Safari": 1234]
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .role: "AXCheckBox",
            .value: false,
            .enabled: true
        ]
        let (handler, _, _) = createHandler(
            bridge: bridge,
            resolver: resolver
        )
        let params = SetValueParameters(
            app: "Safari",
            elementPath: "app(1234)",
            value: .bool(true)
        )
        let response = try await handler.execute(parameters: params)
        #expect(response.success == true)
    }

    @Test("Sets number value")
    func testSetNumberValue() async throws {
        var resolver = MockAppResolver()
        resolver.mockApps = ["iTunes": 1234]
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .role: "AXSlider",
            .value: "50",
            .enabled: true
        ]
        let (handler, _, _) = createHandler(
            bridge: bridge,
            resolver: resolver
        )
        let params = SetValueParameters(
            app: "iTunes",
            elementPath: "app(1234)",
            value: .int(75)
        )
        let response = try await handler.execute(parameters: params)
        #expect(response.success == true)
    }

    @Test("Read-only mode blocks set_value")
    func testReadOnlyMode() async {
        let config = ServerConfiguration(readOnlyMode: true)
        let (handler, _, _) = createHandler(config: config)
        let params = SetValueParameters(
            app: "Safari",
            elementPath: "app(1234)",
            value: .string("test")
        )
        do {
            _ = try await handler.execute(parameters: params)
            Issue.record("Expected error for read-only mode")
        } catch {
            #expect(error is ToolExecutionError)
        }
    }

    @Test("Blocklisted app returns error")
    func testBlocklistedApp() async {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Terminal": 1234]
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .custom("AXBundleIdentifier"): "com.apple.Terminal"
        ]
        let (handler, _, _) = createHandler(
            bridge: bridge,
            resolver: resolver
        )
        let params = SetValueParameters(
            app: "Terminal",
            elementPath: "app(1234)",
            value: .string("test")
        )
        do {
            _ = try await handler.execute(parameters: params)
            Issue.record("Expected error for blocklisted app")
        } catch {
            #expect(error is ToolExecutionError)
        }
    }

    @Test("Invalid path returns error")
    func testInvalidPath() async {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Safari": 1234]
        let (handler, _, _) = createHandler(resolver: resolver)
        let params = SetValueParameters(
            app: "Safari",
            elementPath: "",
            value: .string("test")
        )
        do {
            _ = try await handler.execute(parameters: params)
            Issue.record("Expected error for empty path")
        } catch {
            #expect(error is ToolExecutionError)
        }
    }
}
