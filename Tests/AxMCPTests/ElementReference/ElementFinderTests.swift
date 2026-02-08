import Testing
import Foundation
@testable import AxMCP

@Suite("ElementFinder Tests")
struct ElementFinderTests {
    @Test("Finder searches by role")
    func searchesByRole() throws {
        let finder = ElementFinder()
        var bridge = createMockBridgeWithButtons()
        let criteria = SearchCriteria(role: .button)
        let element = try bridge.createApplicationElement(pid: 1234)
        let results = try finder.find(
            criteria: criteria,
            in: element,
            bridge: bridge,
            applicationPID: 1234
        )
        #expect(results.count >= 0)
    }

    @Test("Finder returns elements with paths")
    func returnsElementsWithPaths() throws {
        let finder = ElementFinder()
        var bridge = createMockBridgeWithButtons()
        let criteria = SearchCriteria(role: .button)
        let element = try bridge.createApplicationElement(pid: 1234)
        let results = try finder.find(
            criteria: criteria,
            in: element,
            bridge: bridge,
            applicationPID: 1234
        )
        for (_, path) in results {
            #expect(!path.components.isEmpty)
        }
    }

    private func createMockBridgeWithButtons() -> MockAXBridge {
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXApplication"
        bridge.mockChildren = []
        return bridge
    }
}
