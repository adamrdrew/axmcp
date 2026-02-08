import Foundation

struct FindElementResponse: Codable, Sendable {
    let elements: [ElementMatch]
    let hasMoreResults: Bool
    let resultCount: Int

    init(
        elements: [ElementMatch],
        hasMoreResults: Bool,
        resultCount: Int
    ) {
        self.elements = elements
        self.hasMoreResults = hasMoreResults
        self.resultCount = resultCount
    }
}
