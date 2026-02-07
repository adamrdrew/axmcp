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

    @Test("Server returns empty tool list")
    func serverReturnsEmptyToolList() {
        let tools = AccessibilityServer.tools()
        #expect(tools.isEmpty)
    }
}
