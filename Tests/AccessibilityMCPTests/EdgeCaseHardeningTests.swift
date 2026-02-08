import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("Edge Case Hardening Tests")
struct EdgeCaseHardeningTests {

    // MARK: - App termination mid-operation

    @Test("Traversal returns error when app terminates (invalidUIElement)")
    func traversalHandlesInvalidElement() throws {
        let traverser = TreeTraverser()
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXApplication"
        bridge.shouldThrowInvalidElement = true
        let options = TreeTraversalOptions(maxDepth: 5)
        let element = bridge.createMockElement()
        #expect(throws: TreeTraversalError.self) {
            try traverser.traverse(
                element: element,
                options: options,
                bridge: bridge
            )
        }
    }

    @Test("GetUITreeHandler returns structured error on invalidUIElement")
    func getUITreeHandlerHandlesTermination() {
        var bridge = MockAXBridge()
        bridge.shouldThrowInvalidElement = true
        var resolver = MockAppResolver()
        resolver.mockApps["TestApp"] = 1234
        let handler = GetUITreeHandler(resolver: resolver, bridge: bridge)
        let params = GetUITreeParameters(app: "TestApp")
        #expect(throws: ToolExecutionError.self) {
            try handler.execute(parameters: params)
        }
    }

    @Test("ErrorConverter converts invalidUIElement with re-traverse guidance")
    func invalidUIElementGuidance() {
        let err = ErrorConverter.convertAccessibilityError(
            .invalidUIElement,
            operation: "get_ui_tree",
            app: "TestApp"
        )
        if case .toolError(let te) = err {
            #expect(te.errorType == "invalid_element")
            #expect(te.guidance?.contains("get_ui_tree") == true)
        }
    }

    @Test("ErrorConverter converts cannotComplete with app busy hint")
    func cannotCompleteGuidance() {
        let err = ErrorConverter.convertAccessibilityError(
            .cannotComplete,
            operation: "perform_action",
            app: "TestApp"
        )
        if case .toolError(let te) = err {
            #expect(te.errorType == "cannot_complete")
            #expect(te.guidance?.contains("busy") == true)
        }
    }

    // MARK: - Non-standard AX implementations

    @Test("Tree traversal handles element with no role gracefully")
    func traverserHandlesNoRole() throws {
        let traverser = TreeTraverser()
        let bridge = MockAXBridge()
        let options = TreeTraversalOptions(maxDepth: 5)
        let element = bridge.createMockElement()
        #expect(throws: TreeTraversalError.self) {
            try traverser.traverse(
                element: element,
                options: options,
                bridge: bridge
            )
        }
    }

    @Test("Tree traversal handles children with missing attributes")
    func traverserChildrenMissingAttributes() throws {
        let traverser = TreeTraverser()
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXApplication"
        bridge.mockChildren = [bridge.createMockElement()]
        let options = TreeTraversalOptions(maxDepth: 2)
        let element = bridge.createMockElement()
        let tree = try traverser.traverse(
            element: element,
            options: options,
            bridge: bridge
        )
        #expect(tree.role == "AXApplication")
    }

    @Test("GetUITreeHandler handles missing title and value")
    func handlerMissingTitleValue() throws {
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXWindow"
        bridge.mockChildren = []
        var resolver = MockAppResolver()
        resolver.mockApps["TestApp"] = 1234
        let handler = GetUITreeHandler(resolver: resolver, bridge: bridge)
        let params = GetUITreeParameters(app: "TestApp", depth: 1)
        let result = try handler.execute(parameters: params)
        #expect(result.tree.title == nil)
        #expect(result.tree.value == nil)
    }

    // MARK: - Stale element references

    @Test("Element path error for stale ref includes path description")
    func staleRefErrorIncludesPath() {
        let path = ElementPath(components: [
            .appByPID(1234),
            .windowByIndex(0)
        ])
        let err = ErrorConverter.convertElementPathError(
            .staleReference(path),
            operation: "perform_action",
            app: "TestApp"
        )
        if case .toolError(let te) = err {
            #expect(te.message.contains("Stale"))
            #expect(te.guidance?.contains("Re-run") == true)
        }
    }

    // MARK: - Observer edge cases

    @Test("Observer error for terminated app has restart guidance")
    func observerTerminatedAppGuidance() {
        let err = ErrorConverter.convertObserverError(
            .applicationTerminated(pid: 9999),
            operation: "observe_changes",
            app: "TestApp"
        )
        if case .toolError(let te) = err {
            #expect(te.errorType == "application_terminated")
            #expect(te.guidance?.contains("Restart") == true)
        }
    }

    @Test("Observer error for already active has wait guidance")
    func observerAlreadyActiveGuidance() {
        let err = ErrorConverter.convertObserverError(
            .observerAlreadyActive(pid: 1234),
            operation: "observe_changes",
            app: "TestApp"
        )
        if case .toolError(let te) = err {
            #expect(te.errorType == "observer_already_active")
            #expect(te.guidance?.contains("Wait") == true)
        }
    }

    @Test("Observer max events error suggests filtering")
    func observerMaxEventsGuidance() {
        let err = ErrorConverter.convertObserverError(
            .maxEventsExceeded(limit: 1000),
            operation: "observe_changes",
            app: "TestApp"
        )
        if case .toolError(let te) = err {
            #expect(te.guidance?.contains("shorter duration") == true)
        }
    }
}
