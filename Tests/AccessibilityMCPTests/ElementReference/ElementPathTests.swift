import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("ElementPath Tests")
struct ElementPathTests {
    @Test("Parse simple path with app and window")
    func parseSimplePath() throws {
        let path = try ElementPath(parsing: "app(1234)/window[0]")
        #expect(path.components.count == 2)
    }

    @Test("Parse path with button by title")
    func parsePathWithButtonByTitle() throws {
        let path = try ElementPath(
            parsing: "app(1234)/window[0]/AXButton[\"Save\"]"
        )
        #expect(path.components.count == 3)
    }

    @Test("Parse path with app by name")
    func parsePathWithAppByName() throws {
        let path = try ElementPath(parsing: "app(\"Finder\")/window[0]")
        #expect(path.components.count == 2)
    }

    @Test("Parse path with window by title")
    func parsePathWithWindowByTitle() throws {
        let path = try ElementPath(
            parsing: "app(1234)/window[\"Document1\"]"
        )
        #expect(path.components.count == 2)
    }

    @Test("Parse path with child by role and index")
    func parsePathWithChildByIndex() throws {
        let path = try ElementPath(
            parsing: "app(1234)/window[0]/AXButton[0]"
        )
        #expect(path.components.count == 3)
    }

    @Test("Parse empty string throws emptyPath")
    func parseEmptyStringThrows() {
        #expect(throws: ElementPathError.emptyPath) {
            try ElementPath(parsing: "")
        }
    }

    @Test("Parse invalid format throws invalidFormat")
    func parseInvalidFormatThrows() {
        #expect(throws: ElementPathError.self) {
            try ElementPath(parsing: "invalid/path/format")
        }
    }
}
