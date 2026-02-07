import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("Tool Parameter Tests")
struct ToolParameterTests {
    @Test("GetUITreeParameters validates positive depth")
    func validatesPositiveDepth() throws {
        let params = GetUITreeParameters(
            app: "Finder",
            depth: 5
        )
        try params.validate()
        #expect(params.effectiveDepth() == 5)
    }

    @Test("GetUITreeParameters rejects zero depth")
    func rejectsZeroDepth() {
        let params = GetUITreeParameters(app: "Finder", depth: 0)
        #expect(
            throws: ToolParameterError.self,
            performing: { try params.validate() }
        )
    }

    @Test("GetUITreeParameters rejects negative depth")
    func rejectsNegativeDepth() {
        let params = GetUITreeParameters(app: "Finder", depth: -1)
        #expect(
            throws: ToolParameterError.self,
            performing: { try params.validate() }
        )
    }

    @Test("GetUITreeParameters uses default depth")
    func usesDefaultDepth() throws {
        let params = GetUITreeParameters(app: "Finder")
        try params.validate()
        #expect(params.effectiveDepth() == 3)
    }

    @Test("FindElementParameters validates positive maxResults")
    func validatesPositiveMaxResults() throws {
        let params = FindElementParameters(
            app: "Finder",
            maxResults: 10
        )
        try params.validate()
        #expect(params.effectiveMaxResults() == 10)
    }

    @Test("FindElementParameters rejects zero maxResults")
    func rejectsZeroMaxResults() {
        let params = FindElementParameters(
            app: "Finder",
            maxResults: 0
        )
        #expect(
            throws: ToolParameterError.self,
            performing: { try params.validate() }
        )
    }

    @Test("FindElementParameters uses default maxResults")
    func usesDefaultMaxResults() throws {
        let params = FindElementParameters(app: "Finder")
        try params.validate()
        #expect(params.effectiveMaxResults() == 20)
    }

    @Test("GetFocusedElementParameters validates successfully")
    func validatesGetFocusedElement() throws {
        let params = GetFocusedElementParameters(app: "Finder")
        try params.validate()
    }

    @Test("ListWindowsParameters uses default includeMinimized")
    func usesDefaultIncludeMinimized() throws {
        let params = ListWindowsParameters()
        try params.validate()
        #expect(params.effectiveIncludeMinimized() == false)
    }

    @Test("ListWindowsParameters respects explicit includeMinimized")
    func respectsExplicitIncludeMinimized() throws {
        let params = ListWindowsParameters(includeMinimized: true)
        try params.validate()
        #expect(params.effectiveIncludeMinimized() == true)
    }

    @Test("GetUITreeParameters encodes and decodes JSON")
    func encodesDecodesGetUITree() throws {
        let original = GetUITreeParameters(
            app: "Finder",
            depth: 5,
            includeAttributes: ["title", "role"],
            filterRoles: ["button", "window"]
        )
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(
            GetUITreeParameters.self,
            from: data
        )
        #expect(decoded.app == original.app)
        #expect(decoded.depth == original.depth)
        #expect(decoded.includeAttributes == original.includeAttributes)
        #expect(decoded.filterRoles == original.filterRoles)
    }

    @Test("FindElementParameters encodes and decodes JSON")
    func encodesDecodesFindElement() throws {
        let original = FindElementParameters(
            app: "Safari",
            role: "button",
            title: "Save",
            maxResults: 10
        )
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(
            FindElementParameters.self,
            from: data
        )
        #expect(decoded.app == original.app)
        #expect(decoded.role == original.role)
        #expect(decoded.title == original.title)
        #expect(decoded.maxResults == original.maxResults)
    }
}
