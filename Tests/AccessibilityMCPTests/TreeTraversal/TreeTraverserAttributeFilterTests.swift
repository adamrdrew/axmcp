import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("TreeTraverser Attribute Filter Tests")
struct TreeTraverserAttributeFilterTests {
    @Test("Filter includes only specified attributes")
    func filterIncludesOnlySpecified() throws {
        let bridge = createFullAttributeBridge()
        let traverser = TreeTraverser()
        let options = TreeTraversalOptions(
            maxDepth: 5,
            includeAttributes: [.title]
        )
        let element = try bridge.createApplicationElement(pid: 1234)
        let tree = try traverser.traverse(
            element: element,
            options: options,
            bridge: bridge
        )
        #expect(tree.title != nil)
        #expect(tree.value == nil)
    }

    @Test("No filter includes all attributes")
    func noFilterIncludesAll() throws {
        let bridge = createFullAttributeBridge()
        let traverser = TreeTraverser()
        let options = TreeTraversalOptions(maxDepth: 5)
        let element = try bridge.createApplicationElement(pid: 1234)
        let tree = try traverser.traverse(
            element: element,
            options: options,
            bridge: bridge
        )
        #expect(tree.title != nil)
        #expect(tree.value != nil)
    }

    private func createFullAttributeBridge() -> MockAXBridge {
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXButton"
        bridge.mockAttributes[.title] = "Save"
        bridge.mockAttributes[.value] = "ButtonValue"
        bridge.mockChildren = []
        return bridge
    }
}
