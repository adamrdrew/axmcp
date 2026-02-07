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

    @Test("Server returns four read tools")
    func serverReturnsFourReadTools() {
        let config = ServerConfiguration(readOnlyMode: true)
        let tools = AccessibilityServer.tools(config: config)
        #expect(tools.count == 4)
        #expect(tools.map { $0.name }.contains("get_ui_tree"))
        #expect(tools.map { $0.name }.contains("find_element"))
        #expect(tools.map { $0.name }.contains("get_focused_element"))
        #expect(tools.map { $0.name }.contains("list_windows"))
    }

    @Test("Server includes write tools when not read-only")
    func serverIncludesWriteTools() {
        let config = ServerConfiguration(readOnlyMode: false)
        let tools = AccessibilityServer.tools(config: config)
        #expect(tools.count == 6)
        #expect(tools.map { $0.name }.contains("perform_action"))
        #expect(tools.map { $0.name }.contains("set_value"))
    }

    @Test("Server excludes write tools in read-only mode")
    func serverExcludesWriteToolsInReadOnly() {
        let config = ServerConfiguration(readOnlyMode: true)
        let tools = AccessibilityServer.tools(config: config)
        let names = tools.map { $0.name }
        #expect(!names.contains("perform_action"))
        #expect(!names.contains("set_value"))
    }
}
