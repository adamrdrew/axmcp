import Testing
import Foundation
import ApplicationServices
@testable import AccessibilityMCP

@Suite("TreeTraverser Tests")
struct TreeTraverserTests {
    @Test("Traversal enforces maxDepth")
    func enforcesMaxDepth() throws {
        let bridge = createDeepMockBridge(depth: 10)
        let traverser = TreeTraverser()
        let options = TreeTraversalOptions(maxDepth: 3)
        let element = try bridge.createApplicationElement(pid: 1234)
        let tree = try traverser.traverse(
            element: element,
            options: options,
            bridge: bridge,
            applicationPID: 1234
        )
        #expect(tree.depth == 0)
        #expect(maxDepth(of: tree) <= 3)
    }

    @Test("Traversal with maxDepth 1 returns only root")
    func maxDepthOneReturnsRoot() throws {
        let bridge = createDeepMockBridge(depth: 5)
        let traverser = TreeTraverser()
        let options = TreeTraversalOptions(maxDepth: 1)
        let element = try bridge.createApplicationElement(pid: 1234)
        let tree = try traverser.traverse(
            element: element,
            options: options,
            bridge: bridge,
            applicationPID: 1234
        )
        #expect(tree.children.isEmpty)
        #expect(tree.childCount > 0)
    }

    @Test("Traversal on shallow tree returns full tree")
    func shallowTreeFullyTraversed() throws {
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXApplication"
        bridge.mockChildren = []
        let traverser = TreeTraverser()
        let options = TreeTraversalOptions(maxDepth: 10)
        let element = try bridge.createApplicationElement(pid: 1234)
        let tree = try traverser.traverse(
            element: element,
            options: options,
            bridge: bridge,
            applicationPID: 1234
        )
        #expect(tree.depth == 0)
        #expect(tree.children.isEmpty)
    }

    @Test("childCount is accurate when truncated")
    func childCountAccurate() throws {
        let bridge = createDeepMockBridge(depth: 5)
        let traverser = TreeTraverser()
        let options = TreeTraversalOptions(maxDepth: 1)
        let element = try bridge.createApplicationElement(pid: 1234)
        let tree = try traverser.traverse(
            element: element,
            options: options,
            bridge: bridge,
            applicationPID: 1234
        )
        #expect(tree.children.isEmpty)
        #expect(tree.childCount == 2)
    }

    private func maxDepth(of node: TreeNode) -> Int {
        if node.children.isEmpty { return node.depth }
        return node.children.map { maxDepth(of: $0) }.max() ?? node.depth
    }

    private func createDeepMockBridge(depth: Int) -> MockAXBridge {
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXApplication"
        bridge.mockChildren = [createMockElement(), createMockElement()]
        return bridge
    }

    private func createMockElement() -> UIElement {
        UIElement(AXUIElementCreateSystemWide())
    }
}
