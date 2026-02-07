import Testing
@testable import AccessibilityMCP

@Suite("Server Tests")
struct ServerTests {
    @Test("Server has correct name")
    func serverHasCorrectName() {
        #expect(AccessibilityServer.name == "accessibility-mcp")
    }

    @Test("Server has correct version")
    func serverHasCorrectVersion() {
        #expect(AccessibilityServer.version == "0.1.0")
    }

    @Test("Server returns four tools")
    func serverReturnsFourTools() {
        let tools = AccessibilityServer.tools()
        #expect(tools.count == 4)
        #expect(tools.map { $0.name }.contains("get_ui_tree"))
        #expect(tools.map { $0.name }.contains("find_element"))
        #expect(tools.map { $0.name }.contains("get_focused_element"))
        #expect(tools.map { $0.name }.contains("list_windows"))
    }
}
