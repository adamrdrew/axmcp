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

    @Test("Server returns read and observe tools in read-only mode")
    func serverReturnsReadAndObserveTools() {
        let config = ServerConfiguration(readOnlyMode: true)
        let tools = ToolRegistry.tools(config: config)
        #expect(tools.count == 5)
        #expect(tools.map { $0.name }.contains("get_ui_tree"))
        #expect(tools.map { $0.name }.contains("find_element"))
        #expect(tools.map { $0.name }.contains("get_focused_element"))
        #expect(tools.map { $0.name }.contains("list_windows"))
        #expect(tools.map { $0.name }.contains("observe_changes"))
    }

    @Test("Server includes write tools when not read-only")
    func serverIncludesWriteTools() {
        let config = ServerConfiguration(readOnlyMode: false)
        let tools = ToolRegistry.tools(config: config)
        #expect(tools.count == 7)
        #expect(tools.map { $0.name }.contains("perform_action"))
        #expect(tools.map { $0.name }.contains("set_value"))
    }

    @Test("Server excludes write tools in read-only mode")
    func serverExcludesWriteToolsInReadOnly() {
        let config = ServerConfiguration(readOnlyMode: true)
        let tools = ToolRegistry.tools(config: config)
        let names = tools.map { $0.name }
        #expect(!names.contains("perform_action"))
        #expect(!names.contains("set_value"))
    }

    @Test("observe_changes visible in both modes")
    func observeChangesVisibleInBothModes() {
        let readOnly = ServerConfiguration(readOnlyMode: true)
        let readWrite = ServerConfiguration(readOnlyMode: false)
        let roTools = ToolRegistry.tools(config: readOnly)
        let rwTools = ToolRegistry.tools(config: readWrite)
        #expect(roTools.map { $0.name }.contains("observe_changes"))
        #expect(rwTools.map { $0.name }.contains("observe_changes"))
    }
}
