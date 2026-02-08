import Foundation

struct TreeNode: Codable, Equatable, Sendable {
    let role: String
    let title: String?
    let value: String?
    let children: [TreeNode]
    let actions: [String]
    let path: String
    let childCount: Int
    let depth: Int

    enum CodingKeys: String, CodingKey {
        case role
        case title
        case value
        case children
        case actions
        case path
        case childCount
        case depth
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(role, forKey: .role)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encode(children, forKey: .children)
        try container.encode(actions, forKey: .actions)
        try container.encode(path, forKey: .path)
        try container.encode(childCount, forKey: .childCount)
        try container.encode(depth, forKey: .depth)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        role = try container.decode(String.self, forKey: .role)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        value = try container.decodeIfPresent(String.self, forKey: .value)
        children = try container.decode([TreeNode].self, forKey: .children)
        actions = try container.decode([String].self, forKey: .actions)
        path = try container.decode(String.self, forKey: .path)
        childCount = try container.decode(Int.self, forKey: .childCount)
        depth = try container.decode(Int.self, forKey: .depth)
    }

    init(
        role: String,
        title: String?,
        value: String?,
        children: [TreeNode],
        actions: [String],
        path: String,
        childCount: Int,
        depth: Int
    ) {
        self.role = role
        self.title = title
        self.value = value
        self.children = children
        self.actions = actions
        self.path = path
        self.childCount = childCount
        self.depth = depth
    }
}
