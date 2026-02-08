import Testing
@testable import AxMCP

@Suite("GetUITree Handler Tests")
struct GetUITreeHandlerTests {
    @Test("Executes get_ui_tree successfully")
    func executesSuccessfully() throws {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Finder": 1234]
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .role: "Application",
            .title: "Finder"
        ]
        bridge.mockChildren = []
        let handler = GetUITreeHandler(resolver: resolver, bridge: bridge)
        let params = GetUITreeParameters(app: "Finder", depth: 2)
        let response = try handler.execute(parameters: params)
        #expect(response.tree.role == "Application")
        #expect(response.depth == 2)
        #expect(response.resultCount >= 1)
    }

    @Test("Throws when app not running")
    func throwsWhenAppNotRunning() {
        var resolver = MockAppResolver()
        resolver.shouldThrowNotRunning = true
        let bridge = MockAXBridge()
        let handler = GetUITreeHandler(resolver: resolver, bridge: bridge)
        let params = GetUITreeParameters(app: "NonExistent")
        #expect(throws: ToolExecutionError.self) {
            try handler.execute(parameters: params)
        }
    }

    @Test("Throws when permissions denied")
    func throwsWhenPermissionsDenied() {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Finder": 1234]
        var bridge = MockAXBridge()
        bridge.shouldThrowPermissionDenied = true
        let handler = GetUITreeHandler(resolver: resolver, bridge: bridge)
        let params = GetUITreeParameters(app: "Finder")
        #expect(throws: ToolExecutionError.self) {
            try handler.execute(parameters: params)
        }
    }

    @Test("Validates depth parameter")
    func validatesDepthParameter() {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Finder": 1234]
        let bridge = MockAXBridge()
        let handler = GetUITreeHandler(resolver: resolver, bridge: bridge)
        let params = GetUITreeParameters(app: "Finder", depth: 0)
        #expect(throws: ToolExecutionError.self) {
            try handler.execute(parameters: params)
        }
    }

    @Test("Uses default depth when not specified")
    func usesDefaultDepth() throws {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Finder": 1234]
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .role: "Application",
            .title: "Finder"
        ]
        bridge.mockChildren = []
        let handler = GetUITreeHandler(resolver: resolver, bridge: bridge)
        let params = GetUITreeParameters(app: "Finder")
        let response = try handler.execute(parameters: params)
        #expect(response.depth == 3)
    }

    @Test("Resolves numeric PID directly")
    func resolvesNumericPID() throws {
        let resolver = MockAppResolver()
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .role: "Application",
            .title: "Test"
        ]
        bridge.mockChildren = []
        let handler = GetUITreeHandler(resolver: resolver, bridge: bridge)
        let params = GetUITreeParameters(app: "9999", depth: 1)
        let response = try handler.execute(parameters: params)
        #expect(response.tree.role == "Application")
    }
}
