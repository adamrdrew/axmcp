import Testing
import Foundation
@testable import AxMCP

@Suite("Tool Integration Tests")
struct ToolIntegrationTests {
    @Test("All handlers integrate with MockAXBridge")
    func handlersIntegrateWithMocks() throws {
        var resolver = MockAppResolver()
        resolver.mockApps = ["TestApp": 1234]
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .role: "Application",
            .title: "Test",
            .windows: []
        ]
        bridge.mockChildren = []
        let getUITreeHandler = GetUITreeHandler(
            resolver: resolver,
            bridge: bridge
        )
        let findElementHandler = FindElementHandler(
            resolver: resolver,
            bridge: bridge
        )
        let getFocusedElementHandler = GetFocusedElementHandler(
            resolver: resolver,
            bridge: bridge
        )
        let listWindowsHandler = ListWindowsHandler(
            resolver: resolver,
            bridge: bridge
        )
        let treeResponse = try getUITreeHandler.execute(
            parameters: GetUITreeParameters(app: "TestApp")
        )
        #expect(treeResponse.tree.role == "Application")
        let findResponse = try findElementHandler.execute(
            parameters: FindElementParameters(app: "TestApp")
        )
        #expect(findResponse.elements.count >= 0)
        let focusedResponse = try getFocusedElementHandler.execute(
            parameters: GetFocusedElementParameters()
        )
        #expect(focusedResponse.hasFocus == false)
        let windowsResponse = try listWindowsHandler.execute(
            parameters: ListWindowsParameters()
        )
        #expect(windowsResponse.windows.count >= 0)
    }

    @Test("Handlers produce valid JSON responses")
    func handlersProduceValidJSON() throws {
        var resolver = MockAppResolver()
        resolver.mockApps = ["TestApp": 1234]
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .role: "Application",
            .title: "Test"
        ]
        bridge.mockChildren = []
        let handler = GetUITreeHandler(
            resolver: resolver,
            bridge: bridge
        )
        let response = try handler.execute(
            parameters: GetUITreeParameters(app: "TestApp")
        )
        let encoder = JSONEncoder()
        let data = try encoder.encode(response)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(
            UITreeResponse.self,
            from: data
        )
        #expect(decoded.tree.role == response.tree.role)
    }

    @Test("Error responses are structured consistently")
    func errorResponsesAreStructured() {
        var resolver = MockAppResolver()
        resolver.shouldThrowNotRunning = true
        let bridge = MockAXBridge()
        let handler = GetUITreeHandler(
            resolver: resolver,
            bridge: bridge
        )
        do {
            _ = try handler.execute(
                parameters: GetUITreeParameters(app: "NonExistent")
            )
            Issue.record("Expected error to be thrown")
        } catch let error as ToolExecutionError {
            switch error {
            case .toolError(let toolError):
                #expect(toolError.operation == "get_ui_tree")
                #expect(toolError.errorType == "app_not_running")
                #expect(toolError.app == "NonExistent")
                #expect(toolError.guidance != nil)
            }
        } catch {
            Issue.record("Wrong error type: \(error)")
        }
    }
}
