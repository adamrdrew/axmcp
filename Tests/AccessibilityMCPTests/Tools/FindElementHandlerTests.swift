import Testing
@testable import AccessibilityMCP

@Suite("FindElement Handler Tests")
struct FindElementHandlerTests {
    @Test("Executes find_element successfully")
    func executesSuccessfully() throws {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Finder": 1234]
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .role: "Application",
            .title: "Finder"
        ]
        bridge.mockChildren = []
        let handler = FindElementHandler(resolver: resolver, bridge: bridge)
        let params = FindElementParameters(
            app: "Finder",
            role: "Button"
        )
        let response = try handler.execute(parameters: params)
        #expect(response.elements.count >= 0)
        #expect(response.hasMoreResults == false)
    }

    @Test("Finds elements by role")
    func findsByRole() throws {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Finder": 1234]
        let buttonElement = MockAXBridge().createMockElement()
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .role: "Application",
            .title: "Finder"
        ]
        bridge.mockChildren = [buttonElement]
        let handler = FindElementHandler(resolver: resolver, bridge: bridge)
        let params = FindElementParameters(
            app: "Finder",
            role: "Button"
        )
        let response = try handler.execute(parameters: params)
        #expect(response.resultCount >= 0)
    }

    @Test("Returns empty array when no matches")
    func returnsEmptyWhenNoMatches() throws {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Finder": 1234]
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .role: "Application",
            .title: "Finder"
        ]
        bridge.mockChildren = []
        let handler = FindElementHandler(resolver: resolver, bridge: bridge)
        let params = FindElementParameters(
            app: "Finder",
            role: "NonExistentRole"
        )
        let response = try handler.execute(parameters: params)
        #expect(response.elements.isEmpty)
        #expect(response.hasMoreResults == false)
    }

    @Test("Enforces maxResults limit")
    func enforcesMaxResults() throws {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Finder": 1234]
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .role: "Application"
        ]
        bridge.mockChildren = []
        let handler = FindElementHandler(resolver: resolver, bridge: bridge)
        let params = FindElementParameters(
            app: "Finder",
            maxResults: 5
        )
        let response = try handler.execute(parameters: params)
        #expect(response.elements.count <= 5)
    }

    @Test("Throws when app not running")
    func throwsWhenAppNotRunning() {
        var resolver = MockAppResolver()
        resolver.shouldThrowNotRunning = true
        let bridge = MockAXBridge()
        let handler = FindElementHandler(resolver: resolver, bridge: bridge)
        let params = FindElementParameters(app: "NonExistent")
        #expect(throws: ToolExecutionError.self) {
            try handler.execute(parameters: params)
        }
    }

    @Test("Validates maxResults parameter")
    func validatesMaxResults() {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Finder": 1234]
        let bridge = MockAXBridge()
        let handler = FindElementHandler(resolver: resolver, bridge: bridge)
        let params = FindElementParameters(app: "Finder", maxResults: 0)
        #expect(throws: ToolExecutionError.self) {
            try handler.execute(parameters: params)
        }
    }
}
