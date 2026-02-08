import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("TreeTraverser Role Filter Tests")
struct TreeTraverserRoleFilterTests {
    @Test("Filter returns only buttons")
    func filterReturnsOnlyButtons() throws {
        let bridge = createMixedRoleBridge()
        let traverser = TreeTraverser()
        let options = TreeTraversalOptions(
            maxDepth: 5,
            filterRoles: [.button]
        )
        let element = try bridge.createApplicationElement(pid: 1234)
        let tree = try traverser.traverse(
            element: element,
            options: options,
            bridge: bridge,
            applicationPID: 1234
        )
        #expect(tree.role == "AXApplication")
    }

    @Test("Filter returns buttons and text fields")
    func filterReturnsMultipleRoles() throws {
        let bridge = createMixedRoleBridge()
        let traverser = TreeTraverser()
        let options = TreeTraversalOptions(
            maxDepth: 5,
            filterRoles: [.button, .textField]
        )
        let element = try bridge.createApplicationElement(pid: 1234)
        let tree = try traverser.traverse(
            element: element,
            options: options,
            bridge: bridge,
            applicationPID: 1234
        )
        #expect(tree.role == "AXApplication")
    }

    @Test("No filter returns all roles")
    func noFilterReturnsAll() throws {
        let bridge = createMixedRoleBridge()
        let traverser = TreeTraverser()
        let options = TreeTraversalOptions(maxDepth: 5)
        let element = try bridge.createApplicationElement(pid: 1234)
        let tree = try traverser.traverse(
            element: element,
            options: options,
            bridge: bridge,
            applicationPID: 1234
        )
        #expect(tree.role == "AXApplication")
    }

    private func createMixedRoleBridge() -> MockAXBridge {
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXApplication"
        bridge.mockChildren = []
        return bridge
    }
}
