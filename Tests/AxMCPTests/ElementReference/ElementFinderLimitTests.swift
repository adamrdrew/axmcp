import Testing
import Foundation
@testable import AxMCP

@Suite("ElementFinder Limit Tests")
struct ElementFinderLimitTests {
    @Test("Finder enforces maxResults limit")
    func enforcesMaxResults() throws {
        let finder = ElementFinder()
        var bridge = createMockBridge()
        let criteria = SearchCriteria(maxResults: 5)
        let element = try bridge.createApplicationElement(pid: 1234)
        let results = try finder.find(
            criteria: criteria,
            in: element,
            bridge: bridge,
            applicationPID: 1234
        )
        #expect(results.count <= 5)
    }

    @Test("Finder returns fewer results when tree is small")
    func returnsFewerWhenSmall() throws {
        let finder = ElementFinder()
        var bridge = createSmallMockBridge()
        let criteria = SearchCriteria(maxResults: 100)
        let element = try bridge.createApplicationElement(pid: 1234)
        let results = try finder.find(
            criteria: criteria,
            in: element,
            bridge: bridge,
            applicationPID: 1234
        )
        #expect(results.count <= 100)
    }

    @Test("Default maxResults is 20")
    func defaultMaxResultsIs20() {
        let criteria = SearchCriteria()
        #expect(criteria.maxResults == 20)
    }

    private func createMockBridge() -> MockAXBridge {
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXApplication"
        bridge.mockChildren = []
        return bridge
    }

    private func createSmallMockBridge() -> MockAXBridge {
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXApplication"
        bridge.mockChildren = []
        return bridge
    }
}
