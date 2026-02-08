import Testing
@testable import AccessibilityMCP

@Suite("AXBridge Windows Tests")
struct AXBridgeWindowsTests {
    @Test("getWindows returns window arrays correctly")
    func getWindowsReturnsWindowArrays() throws {
        var mock = MockAXBridge()
        let window1 = try mock.createSystemWideElement()
        let window2 = try mock.createSystemWideElement()
        mock.mockAttributes[.windows] = [window1, window2]

        let element = try mock.createSystemWideElement()
        let windows = try mock.getWindows(from: element)

        #expect(windows.count == 2)
    }

    @Test("getWindows returns empty array when no windows attribute")
    func getWindowsReturnsEmptyWhenNoAttribute() throws {
        let mock = MockAXBridge()
        let element = try mock.createSystemWideElement()
        let windows = try mock.getWindows(from: element)

        #expect(windows.isEmpty)
    }

    @Test("getWindows type safety verified with CFArray conversion")
    func getWindowsTypeSafety() throws {
        var mock = MockAXBridge()
        let window1 = try mock.createSystemWideElement()
        let window2 = try mock.createSystemWideElement()
        let window3 = try mock.createSystemWideElement()
        mock.mockAttributes[.windows] = [window1, window2, window3]

        let element = try mock.createSystemWideElement()
        let windows = try mock.getWindows(from: element)

        #expect(windows.count == 3)
    }

    @Test("getWindows handles permission denied error")
    func getWindowsPermissionDenied() throws {
        var mock = MockAXBridge()
        let element = try mock.createSystemWideElement()
        mock.shouldThrowPermissionDenied = true

        #expect(throws: AccessibilityError.self) {
            try mock.getWindows(from: element)
        }
    }

    @Test("getWindows handles invalid element error")
    func getWindowsInvalidElement() throws {
        var mock = MockAXBridge()
        let element = try mock.createSystemWideElement()
        mock.shouldThrowInvalidElement = true

        #expect(throws: AccessibilityError.self) {
            try mock.getWindows(from: element)
        }
    }

    @Test("getWindows with single window returns array with one element")
    func getWindowsSingleWindow() throws {
        var mock = MockAXBridge()
        let window = try mock.createSystemWideElement()
        mock.mockAttributes[.windows] = [window]

        let element = try mock.createSystemWideElement()
        let windows = try mock.getWindows(from: element)

        #expect(windows.count == 1)
    }
}
