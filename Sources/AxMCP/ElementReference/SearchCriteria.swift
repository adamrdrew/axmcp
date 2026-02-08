import Foundation

struct SearchCriteria: Sendable {
    let role: ElementRole?
    let titleSubstring: String?
    let value: String?
    let identifier: String?
    let caseSensitive: Bool
    let maxResults: Int

    init(
        role: ElementRole? = nil,
        titleSubstring: String? = nil,
        value: String? = nil,
        identifier: String? = nil,
        caseSensitive: Bool = false,
        maxResults: Int = 20
    ) {
        self.role = role
        self.titleSubstring = titleSubstring
        self.value = value
        self.identifier = identifier
        self.caseSensitive = caseSensitive
        self.maxResults = maxResults
    }
}
