import Foundation

struct UITreeResponse: Codable, Sendable {
    let tree: TreeNode
    let hasMoreResults: Bool
    let resultCount: Int
    let depth: Int

    init(
        tree: TreeNode,
        hasMoreResults: Bool,
        resultCount: Int,
        depth: Int
    ) {
        self.tree = tree
        self.hasMoreResults = hasMoreResults
        self.resultCount = resultCount
        self.depth = depth
    }
}
