import Foundation

struct ElementPath: Equatable, Hashable, Sendable {
    let components: [ElementPathComponent]

    init(components: [ElementPathComponent]) {
        self.components = components
    }

    init(parsing string: String) throws(ElementPathError) {
        guard !string.isEmpty else {
            throw ElementPathError.emptyPath
        }
        let parts = string.split(separator: "/").map(String.init)
        var parsed: [ElementPathComponent] = []
        for part in parts {
            parsed.append(try Self.parseComponent(part))
        }
        self.components = parsed
    }

    func toString() -> String {
        components.map { $0.toString() }.joined(separator: "/")
    }

    static func parseComponent(
        _ string: String
    ) throws(ElementPathError) -> ElementPathComponent {
        if string.hasPrefix("app(") {
            return try parseApp(string)
        } else if string.hasPrefix("window[") {
            return try parseWindow(string)
        } else {
            return try parseChild(string)
        }
    }
}

extension ElementPath: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        try self.init(parsing: string)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(toString())
    }
}
