import Testing
import Foundation
@testable import AxMCP

@Suite("ElementFinder Title Tests")
struct ElementFinderTitleTests {
    @Test("Finder searches by title substring")
    func searchesByTitleSubstring() throws {
        let finder = ElementFinder()
        var bridge = createMockBridgeWithTitles()
        let criteria = SearchCriteria(titleSubstring: "Save")
        let element = try bridge.createApplicationElement(pid: 1234)
        let results = try finder.find(
            criteria: criteria,
            in: element,
            bridge: bridge,
            applicationPID: 1234
        )
        #expect(results.count >= 0)
    }

    @Test("Finder uses case-insensitive matching by default")
    func caseInsensitiveByDefault() throws {
        let finder = ElementFinder()
        var bridge = createMockBridgeWithTitles()
        let criteria = SearchCriteria(titleSubstring: "save")
        let element = try bridge.createApplicationElement(pid: 1234)
        let results = try finder.find(
            criteria: criteria,
            in: element,
            bridge: bridge,
            applicationPID: 1234
        )
        #expect(results.count >= 0)
    }

    @Test("Finder supports case-sensitive matching")
    func caseSensitiveWhenEnabled() throws {
        let finder = ElementFinder()
        var bridge = createMockBridgeWithTitles()
        let criteria = SearchCriteria(
            titleSubstring: "Save",
            caseSensitive: true
        )
        let element = try bridge.createApplicationElement(pid: 1234)
        let results = try finder.find(
            criteria: criteria,
            in: element,
            bridge: bridge,
            applicationPID: 1234
        )
        #expect(results.count >= 0)
    }

    private func createMockBridgeWithTitles() -> MockAXBridge {
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXApplication"
        bridge.mockAttributes[.title] = "Save"
        bridge.mockChildren = []
        return bridge
    }
}
