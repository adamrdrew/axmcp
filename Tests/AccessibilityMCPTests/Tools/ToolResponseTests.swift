import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("Tool Response Tests")
struct ToolResponseTests {
    @Test("UITreeResponse encodes to JSON")
    func encodesUITreeResponse() throws {
        let tree = TreeNode(
            role: "Application",
            title: "Finder",
            value: nil,
            children: [],
            actions: [],
            path: "app(1234)",
            childCount: 0,
            depth: 0
        )
        let response = UITreeResponse(
            tree: tree,
            hasMoreResults: false,
            resultCount: 1,
            depth: 3
        )
        let encoder = JSONEncoder()
        let data = try encoder.encode(response)
        let decoded = try JSONDecoder().decode(
            UITreeResponse.self,
            from: data
        )
        #expect(decoded.tree.role == "Application")
        #expect(decoded.hasMoreResults == false)
        #expect(decoded.resultCount == 1)
        #expect(decoded.depth == 3)
    }

    @Test("FindElementResponse encodes to JSON")
    func encodesFindElementResponse() throws {
        let match = ElementMatch(
            role: "Button",
            title: "Save",
            value: nil,
            path: "app(1234)/window[0]/button[Save]"
        )
        let response = FindElementResponse(
            elements: [match],
            hasMoreResults: false,
            resultCount: 1
        )
        let encoder = JSONEncoder()
        let data = try encoder.encode(response)
        let decoded = try JSONDecoder().decode(
            FindElementResponse.self,
            from: data
        )
        #expect(decoded.elements.count == 1)
        #expect(decoded.elements[0].role == "Button")
        #expect(decoded.hasMoreResults == false)
    }

    @Test("FocusedElementResponse encodes with element")
    func encodesFocusedWithElement() throws {
        let element = ElementInfo(
            role: "TextField",
            title: "Search",
            value: "query",
            path: "app(1234)/window[0]/textfield[0]",
            actions: ["AXPress"]
        )
        let response = FocusedElementResponse(
            element: element,
            hasFocus: true
        )
        let data = try JSONEncoder().encode(response)
        let decoded = try JSONDecoder().decode(
            FocusedElementResponse.self,
            from: data
        )
        #expect(decoded.element?.role == "TextField")
        #expect(decoded.hasFocus == true)
    }

    @Test("FocusedElementResponse encodes without element")
    func encodesFocusedWithoutElement() throws {
        let response = FocusedElementResponse(
            element: nil,
            hasFocus: false
        )
        let data = try JSONEncoder().encode(response)
        let decoded = try JSONDecoder().decode(
            FocusedElementResponse.self,
            from: data
        )
        #expect(decoded.element == nil)
        #expect(decoded.hasFocus == false)
    }

    @Test("ListWindowsResponse encodes to JSON")
    func encodesListWindowsResponse() throws {
        let window = WindowInfo(
            title: "Document1",
            position: WindowInfo.Position(x: 100, y: 200),
            size: WindowInfo.Size(width: 800, height: 600),
            minimized: false,
            frontmost: true,
            app: "TextEdit"
        )
        let response = ListWindowsResponse(windows: [window])
        let data = try JSONEncoder().encode(response)
        let decoded = try JSONDecoder().decode(
            ListWindowsResponse.self,
            from: data
        )
        #expect(decoded.windows.count == 1)
        #expect(decoded.windows[0].title == "Document1")
        #expect(decoded.windows[0].position.x == 100)
        #expect(decoded.windows[0].size.width == 800)
    }

    @Test("ToolError encodes complete error")
    func encodesCompleteToolError() throws {
        let error = ToolError(
            operation: "get_ui_tree",
            errorType: "app_not_found",
            message: "Application 'NonExistent' is not running",
            app: "NonExistent",
            guidance: "Check that the application is running"
        )
        let data = try JSONEncoder().encode(error)
        let decoded = try JSONDecoder().decode(ToolError.self, from: data)
        #expect(decoded.operation == "get_ui_tree")
        #expect(decoded.errorType == "app_not_found")
        #expect(decoded.app == "NonExistent")
        #expect(decoded.guidance != nil)
    }

    @Test("ToolError encodes minimal error")
    func encodesMinimalToolError() throws {
        let error = ToolError(
            operation: "find_element",
            errorType: "timeout",
            message: "Operation timed out"
        )
        let data = try JSONEncoder().encode(error)
        let decoded = try JSONDecoder().decode(ToolError.self, from: data)
        #expect(decoded.operation == "find_element")
        #expect(decoded.app == nil)
        #expect(decoded.guidance == nil)
    }
}
