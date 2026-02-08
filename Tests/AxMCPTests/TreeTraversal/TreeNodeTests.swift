import Testing
import Foundation
@testable import AxMCP

@Suite("TreeNode Tests")
struct TreeNodeTests {
    @Test("TreeNode encodes to JSON")
    func encodesToJSON() throws {
        let node = TreeNode(
            role: "AXButton",
            title: "Save",
            value: nil,
            children: [],
            actions: ["AXPress"],
            path: "app(1234)/window[0]/button[0]",
            childCount: 0,
            depth: 2
        )
        let encoder = JSONEncoder()
        let data = try encoder.encode(node)
        #expect(data.count > 0)
    }

    @Test("TreeNode decodes from JSON")
    func decodesFromJSON() throws {
        let json = """
        {
            "role": "AXButton",
            "title": "Save",
            "value": null,
            "children": [],
            "actions": ["AXPress"],
            "path": "app(1234)/window[0]/button[0]",
            "childCount": 0,
            "depth": 2
        }
        """
        let decoder = JSONDecoder()
        let data = json.data(using: .utf8)!
        let node = try decoder.decode(TreeNode.self, from: data)
        #expect(node.role == "AXButton")
        #expect(node.title == "Save")
    }

    @Test("TreeNode round-trips through JSON")
    func roundTrips() throws {
        let original = TreeNode(
            role: "AXWindow",
            title: "Document",
            value: "Content",
            children: [],
            actions: ["AXClose"],
            path: "app(1234)/window[0]",
            childCount: 5,
            depth: 1
        )
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(TreeNode.self, from: data)
        #expect(decoded == original)
    }

    @Test("TreeNode with nested children serializes")
    func nestedChildrenSerialize() throws {
        let child = TreeNode(
            role: "AXButton",
            title: "OK",
            value: nil,
            children: [],
            actions: [],
            path: "app(1234)/window[0]/button[0]",
            childCount: 0,
            depth: 2
        )
        let parent = TreeNode(
            role: "AXWindow",
            title: "Dialog",
            value: nil,
            children: [child],
            actions: [],
            path: "app(1234)/window[0]",
            childCount: 1,
            depth: 1
        )
        let encoder = JSONEncoder()
        let data = try encoder.encode(parent)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(TreeNode.self, from: data)
        #expect(decoded.children.count == 1)
        #expect(decoded.children[0].title == "OK")
    }
}
