import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("PerformActionHandler Tests")
struct PerformActionHandlerTests {
    func createHandler(
        config: ServerConfiguration = ServerConfiguration(),
        bridge: MockAXBridge = MockAXBridge(),
        resolver: MockAppResolver = MockAppResolver()
    ) -> (PerformActionHandler, ApplicationBlocklist, RateLimiter) {
        let blocklist = ApplicationBlocklist(
            additionalBlockedIDs: config.blockedBundleIDs
        )
        let rateLimiter = RateLimiter(
            maxActionsPerSecond: config.rateLimitPerSecond
        )
        let handler = PerformActionHandler(
            resolver: resolver,
            bridge: bridge,
            blocklist: blocklist,
            rateLimiter: rateLimiter,
            config: config
        )
        return (handler, blocklist, rateLimiter)
    }

    @Test("Success path performs action and returns state")
    func testSuccess() async throws {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Safari": 1234]
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .role: "AXButton",
            .title: "OK",
            .enabled: true
        ]
        bridge.mockActions = [.press]
        let (handler, _, _) = createHandler(
            bridge: bridge,
            resolver: resolver
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
    }

    @Test("Read-only mode blocks action")
    func testReadOnlyMode() async {
        let config = ServerConfiguration(readOnlyMode: true)
        let (handler, _, _) = createHandler(config: config)
        let params = PerformActionParameters(
            app: "Safari",
            elementPath: "app(1234)",
            action: "AXPress"
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
        let params = PerformActionParameters(
            app: "Terminal",
            elementPath: "app(1234)",
            action: "AXPress"
        )
        do {
            _ = try await handler.execute(parameters: params)
            Issue.record("Expected error for blocklisted app")
        } catch {
            #expect(error is ToolExecutionError)
        }
    }

    @Test("Invalid element path returns error")
    func testInvalidPath() async {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Safari": 1234]
        let (handler, _, _) = createHandler(resolver: resolver)
        let params = PerformActionParameters(
            app: "Safari",
            elementPath: "",
            action: "AXPress"
        )
        do {
            _ = try await handler.execute(parameters: params)
            Issue.record("Expected error for empty path")
        } catch {
            #expect(error is ToolExecutionError)
        }
    }

    @Test("Action not supported returns error")
    func testActionNotSupported() async {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Safari": 1234]
        var bridge = MockAXBridge()
        bridge.mockActions = []
        let (handler, _, _) = createHandler(
            bridge: bridge,
            resolver: resolver
        )
        let params = PerformActionParameters(
            app: "Safari",
            elementPath: "app(1234)",
            action: "AXPress"
        )
        do {
            _ = try await handler.execute(parameters: params)
            Issue.record("Expected error for unsupported action")
        } catch {
            #expect(error is ToolExecutionError)
        }
    }
}
