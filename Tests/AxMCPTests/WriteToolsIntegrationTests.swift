import Testing
import Foundation
@testable import AxMCP

@Suite("Write Tools Integration Tests")
struct WriteToolsIntegrationTests {
    func createTestContext(
        readOnlyMode: Bool = false
    ) -> (ServerContext, MockAppResolver, MockAXBridge) {
        let config = ServerConfiguration(
            readOnlyMode: readOnlyMode,
            rateLimitPerSecond: 10,
            blockedBundleIDs: []
        )
        let context = ServerContext(configuration: config)
        let resolver = MockAppResolver()
        let bridge = MockAXBridge()
        return (context, resolver, bridge)
    }

    @Test("perform_action full flow: resolve, validate, perform, return state")
    func testPerformActionFullFlow() async throws {
        let (context, resolver, bridge) = createTestContext()
        var resolverVar = resolver
        resolverVar.mockApps = ["Safari": 1234]
        var bridgeVar = bridge
        bridgeVar.mockAttributes = [
            .role: "AXButton",
            .title: "OK",
            .enabled: true
        ]
        bridgeVar.mockActions = [.press]
        let handler = PerformActionHandler(
            resolver: resolverVar,
            bridge: bridgeVar,
            blocklist: await context.getBlocklist(),
            rateLimiter: await context.getRateLimiter(),
            config: await context.getConfiguration()
        )
        let params = PerformActionParameters(
            app: "Safari",
            elementPath: "app(1234)",
            action: "AXPress"
        )
        let response = try await handler.execute(parameters: params)
        #expect(response.success == true)
        #expect(response.action == "AXPress")
        #expect(response.elementState.role == "AXButton")
        #expect(response.elementState.title == "OK")
    }

    @Test("set_value full flow: resolve, coerce, set, return state")
    func testSetValueFullFlow() async throws {
        let (context, resolver, bridge) = createTestContext()
        var resolverVar = resolver
        resolverVar.mockApps = ["TextEdit": 1234]
        var bridgeVar = bridge
        bridgeVar.mockAttributes = [
            .role: "AXTextField",
            .value: "old value",
            .enabled: true
        ]
        let handler = SetValueHandler(
            resolver: resolverVar,
            bridge: bridgeVar,
            blocklist: await context.getBlocklist(),
            rateLimiter: await context.getRateLimiter(),
            config: await context.getConfiguration()
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

    @Test("Read-only mode blocks writes but allows reads")
    func testReadOnlyModeBlocksWrites() async throws {
        let config = ServerConfiguration(readOnlyMode: true)
        let context = ServerContext(configuration: config)
        let handler = PerformActionHandler(
            resolver: MockAppResolver(),
            bridge: MockAXBridge(),
            blocklist: await context.getBlocklist(),
            rateLimiter: await context.getRateLimiter(),
            config: await context.getConfiguration()
        )
        let params = PerformActionParameters(
            app: "Safari",
            elementPath: "app(1234)",
            action: "AXPress"
        )
        do {
            _ = try await handler.execute(parameters: params)
            Issue.record("Expected read-only error")
        } catch {
            #expect(error is ToolExecutionError)
        }
    }

    @Test("Blocklist blocks writes on specific apps")
    func testBlocklistBlocksWrites() async throws {
        let (context, _, bridge) = createTestContext()
        var resolverVar = MockAppResolver()
        resolverVar.mockApps = ["Terminal": 1234]
        var bridgeVar = bridge
        bridgeVar.mockAttributes = [
            .custom("AXBundleIdentifier"): "com.apple.Terminal"
        ]
        let handler = PerformActionHandler(
            resolver: resolverVar,
            bridge: bridgeVar,
            blocklist: await context.getBlocklist(),
            rateLimiter: await context.getRateLimiter(),
            config: await context.getConfiguration()
        )
        let params = PerformActionParameters(
            app: "Terminal",
            elementPath: "app(1234)",
            action: "AXPress"
        )
        do {
            _ = try await handler.execute(parameters: params)
            Issue.record("Expected blocklist error")
        } catch {
            #expect(error is ToolExecutionError)
        }
    }

    @Test("Rate limiter delays bursts")
    func testRateLimiterDelays() async throws {
        let config = ServerConfiguration(
            rateLimitPerSecond: 2
        )
        let context = ServerContext(configuration: config)
        var resolver = MockAppResolver()
        resolver.mockApps = ["Safari": 1234]
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .role: "AXButton",
            .enabled: true
        ]
        bridge.mockActions = [.press]
        let handler = PerformActionHandler(
            resolver: resolver,
            bridge: bridge,
            blocklist: await context.getBlocklist(),
            rateLimiter: await context.getRateLimiter(),
            config: await context.getConfiguration()
        )
        let params = PerformActionParameters(
            app: "Safari",
            elementPath: "app(1234)",
            action: "AXPress"
        )
        let r1 = try await handler.execute(parameters: params)
        let r2 = try await handler.execute(parameters: params)
        let r3 = try await handler.execute(parameters: params)
        #expect(r1.rateLimitWarning == nil)
        #expect(r2.rateLimitWarning == nil)
        #expect(r3.rateLimitWarning != nil)
    }

    @Test("Invalid app returns structured error")
    func testInvalidAppError() async throws {
        let (context, resolver, bridge) = createTestContext()
        var resolverVar = resolver
        resolverVar.shouldThrowNotRunning = true
        let handler = PerformActionHandler(
            resolver: resolverVar,
            bridge: bridge,
            blocklist: await context.getBlocklist(),
            rateLimiter: await context.getRateLimiter(),
            config: await context.getConfiguration()
        )
        let params = PerformActionParameters(
            app: "NonExistentApp",
            elementPath: "app(1234)",
            action: "AXPress"
        )
        do {
            _ = try await handler.execute(parameters: params)
            Issue.record("Expected app resolution error")
        } catch {
            #expect(error is ToolExecutionError)
        }
    }

    @Test("Post-action state is present in success responses")
    func testPostActionStatePresent() async throws {
        let (context, resolver, bridge) = createTestContext()
        var resolverVar = resolver
        resolverVar.mockApps = ["Safari": 1234]
        var bridgeVar = bridge
        bridgeVar.mockAttributes = [
            .role: "AXButton",
            .title: "OK",
            .value: "button-value",
            .enabled: true,
            .focused: false
        ]
        bridgeVar.mockActions = [.press]
        let handler = PerformActionHandler(
            resolver: resolverVar,
            bridge: bridgeVar,
            blocklist: await context.getBlocklist(),
            rateLimiter: await context.getRateLimiter(),
            config: await context.getConfiguration()
        )
        let params = PerformActionParameters(
            app: "Safari",
            elementPath: "app(1234)",
            action: "AXPress"
        )
        let response = try await handler.execute(parameters: params)
        #expect(response.elementState.role == "AXButton")
        #expect(response.elementState.title == "OK")
        #expect(response.elementState.enabled == true)
        #expect(response.elementState.path == "app(1234)")
    }
}
