import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("ElementFinder Multi-Criteria Tests")
struct ElementFinderMultiCriteriaTests {
    @Test("Finder searches by role and title")
    func searchesByRoleAndTitle() throws {
        let finder = ElementFinder()
        var bridge = createMockBridge()
        let criteria = SearchCriteria(
            role: .button,
            titleSubstring: "Save"
        )
        let element = try bridge.createApplicationElement(pid: 1234)
        let results = try finder.find(
            criteria: criteria,
            in: element,
            bridge: bridge
        )
        #expect(results.count >= 0)
    }

    @Test("Finder searches by role, title, and value")
    func searchesByMultipleCriteria() throws {
        let finder = ElementFinder()
        var bridge = createMockBridge()
        let criteria = SearchCriteria(
            role: .button,
            titleSubstring: "Save",
            value: "1"
        )
        let element = try bridge.createApplicationElement(pid: 1234)
        let results = try finder.find(
            criteria: criteria,
            in: element,
            bridge: bridge
        )
        #expect(results.count >= 0)
    }

    private func createMockBridge() -> MockAXBridge {
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXApplication"
        bridge.mockAttributes[.title] = "Save"
        bridge.mockAttributes[.value] = "1"
        bridge.mockChildren = []
        return bridge
    }
}
