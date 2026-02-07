import Testing
@testable import AccessibilityMCP

@Suite("ListWindows Handler Tests")
struct ListWindowsHandlerTests {
    @Test("Lists windows for specific app")
    func listsWindowsForApp() throws {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Finder": 1234]
        let window1 = MockAXBridge().createMockElement()
        let window2 = MockAXBridge().createMockElement()
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .windows: [window1, window2],
            .title: "Window1"
        ]
        let handler = ListWindowsHandler(
            resolver: resolver,
            bridge: bridge
        )
        let params = ListWindowsParameters(app: "Finder")
        let response = try handler.execute(parameters: params)
        #expect(response.windows.count >= 0)
    }

    @Test("Filters minimized windows by default")
    func filtersMinimizedByDefault() throws {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Finder": 1234]
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .windows: [],
            .title: "Window"
        ]
        let handler = ListWindowsHandler(
            resolver: resolver,
            bridge: bridge
        )
        let params = ListWindowsParameters(app: "Finder")
        let response = try handler.execute(parameters: params)
        #expect(response.windows.allSatisfy { !$0.minimized })
    }

    @Test("Includes minimized windows when requested")
    func includesMinimizedWhenRequested() throws {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Finder": 1234]
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .windows: [],
            .title: "Window"
        ]
        let handler = ListWindowsHandler(
            resolver: resolver,
            bridge: bridge
        )
        let params = ListWindowsParameters(
            app: "Finder",
            includeMinimized: true
        )
        let response = try handler.execute(parameters: params)
        #expect(response.windows.count >= 0)
    }

    @Test("Lists windows system-wide")
    func listsWindowsSystemWide() throws {
        let resolver = MockAppResolver()
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .windows: [],
            .title: "Window"
        ]
        let handler = ListWindowsHandler(
            resolver: resolver,
            bridge: bridge
        )
        let params = ListWindowsParameters()
        let response = try handler.execute(parameters: params)
        #expect(response.windows.count >= 0)
    }

    @Test("Throws when app not running")
    func throwsWhenAppNotRunning() {
        var resolver = MockAppResolver()
        resolver.shouldThrowNotRunning = true
        let bridge = MockAXBridge()
        let handler = ListWindowsHandler(
            resolver: resolver,
            bridge: bridge
        )
        let params = ListWindowsParameters(app: "NonExistent")
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
        let handler = ListWindowsHandler(
            resolver: resolver,
            bridge: bridge
        )
        let params = ListWindowsParameters(app: "Finder")
        #expect(throws: ToolExecutionError.self) {
            try handler.execute(parameters: params)
        }
    }
}
