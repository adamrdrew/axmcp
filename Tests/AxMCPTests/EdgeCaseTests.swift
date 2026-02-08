import Testing
import Foundation
@testable import AxMCP

@Suite("Edge Case Tests")
struct EdgeCaseTests {
    @Test("TreeTraverser handles empty tree")
    func traverserHandlesEmptyTree() throws {
        let traverser = TreeTraverser()
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXApplication"
        bridge.mockChildren = []
        let options = TreeTraversalOptions(maxDepth: 5)
        let element = try bridge.createApplicationElement(pid: 1234)
        let tree = try traverser.traverse(
            element: element,
            options: options,
            bridge: bridge,
            applicationPID: 1234
        )
        #expect(tree.children.isEmpty)
        #expect(tree.childCount == 0)
    }

    @Test("ElementFinder returns empty array on no matches")
    func finderReturnsEmptyOnNoMatches() throws {
        let finder = ElementFinder()
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXApplication"
        bridge.mockChildren = []
        let criteria = SearchCriteria(role: .button)
        let element = try bridge.createApplicationElement(pid: 1234)
        let results = try finder.find(
            criteria: criteria,
            in: element,
            bridge: bridge,
            applicationPID: 1234
        )
        #expect(results.isEmpty)
    }

    @Test("ElementPath with only app component is valid")
    func pathWithOnlyAppIsValid() throws {
        let path = try ElementPath(parsing: "app(1234)")
        #expect(path.components.count == 1)
    }

    @Test("TreeTraverser handles missing attributes gracefully")
    func traverserHandlesMissingAttributes() throws {
        let traverser = TreeTraverser()
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXButton"
        bridge.mockChildren = []
        let options = TreeTraversalOptions(maxDepth: 5)
        let element = try bridge.createApplicationElement(pid: 1234)
        let tree = try traverser.traverse(
            element: element,
            options: options,
            bridge: bridge,
            applicationPID: 1234
        )
        #expect(tree.title == nil)
        #expect(tree.value == nil)
    }
}
