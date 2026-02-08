import Foundation

struct TreeTraversalOptions: Sendable {
    let maxDepth: Int
    let filterRoles: Set<ElementRole>?
    let includeAttributes: Set<ElementAttribute>?
    let timeout: TimeInterval

    init(
        maxDepth: Int,
        filterRoles: Set<ElementRole>? = nil,
        includeAttributes: Set<ElementAttribute>? = nil,
        timeout: TimeInterval = 5.0
    ) {
        self.maxDepth = maxDepth
        self.filterRoles = filterRoles
        self.includeAttributes = includeAttributes
        self.timeout = timeout
    }
}
