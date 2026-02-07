import Testing
@testable import AccessibilityMCP

@Suite("GetFocusedElement Handler Tests")
struct GetFocusedElementHandlerTests {
    @Test("Returns focused element when present")
    func returnsFocusedElement() throws {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Finder": 1234]
        let focusedElement = MockAXBridge().createMockElement()
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .focused: focusedElement,
            .role: "TextField",
            .title: "Search"
        ]
        let handler = GetFocusedElementHandler(
            resolver: resolver,
            bridge: bridge
        )
        let params = GetFocusedElementParameters()
        let response = try handler.execute(parameters: params)
        #expect(response.hasFocus == true)
        #expect(response.element != nil)
    }

    @Test("Returns no focus when no element focused")
    func returnsNoFocus() throws {
        let resolver = MockAppResolver()
        var bridge = MockAXBridge()
        bridge.mockAttributes = [:]
        let handler = GetFocusedElementHandler(
            resolver: resolver,
            bridge: bridge
        )
        let params = GetFocusedElementParameters()
        let response = try handler.execute(parameters: params)
        #expect(response.hasFocus == false)
        #expect(response.element == nil)
    }

    @Test("Gets focused element for specific app")
    func getsFocusedForApp() throws {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Finder": 1234]
        let focusedElement = MockAXBridge().createMockElement()
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .focused: focusedElement,
            .role: "TextField"
        ]
        let handler = GetFocusedElementHandler(
            resolver: resolver,
            bridge: bridge
        )
        let params = GetFocusedElementParameters(app: "Finder")
        let response = try handler.execute(parameters: params)
        #expect(response.hasFocus == true)
    }

    @Test("Gets focused element system-wide")
    func getsFocusedSystemWide() throws {
        let resolver = MockAppResolver()
        let focusedElement = MockAXBridge().createMockElement()
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .focused: focusedElement,
            .role: "Button"
        ]
        let handler = GetFocusedElementHandler(
            resolver: resolver,
            bridge: bridge
        )
        let params = GetFocusedElementParameters()
        let response = try handler.execute(parameters: params)
        #expect(response.hasFocus == true)
    }

    @Test("Throws when app not running")
    func throwsWhenAppNotRunning() {
        var resolver = MockAppResolver()
        resolver.shouldThrowNotRunning = true
        let bridge = MockAXBridge()
        let handler = GetFocusedElementHandler(
            resolver: resolver,
            bridge: bridge
        )
        let params = GetFocusedElementParameters(app: "NonExistent")
        #expect(throws: ToolExecutionError.self) {
            try handler.execute(parameters: params)
        }
    }

    @Test("Throws when permissions denied")
    func throwsWhenPermissionsDenied() {
        let resolver = MockAppResolver()
        var bridge = MockAXBridge()
        bridge.shouldThrowPermissionDenied = true
        let handler = GetFocusedElementHandler(
            resolver: resolver,
            bridge: bridge
        )
        let params = GetFocusedElementParameters()
        #expect(throws: ToolExecutionError.self) {
            try handler.execute(parameters: params)
        }
    }
}
