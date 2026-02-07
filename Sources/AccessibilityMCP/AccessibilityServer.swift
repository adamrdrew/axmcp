import MCP

struct AccessibilityServer {
    static let name = "accessibility-mcp"
    static let version = "0.1.0"

    static func create() -> Server {
        Server(
            name: name,
            version: version,
            capabilities: .init(tools: .init())
        )
    }

    static func registerHandlers(
        on server: Server
    ) async {
        await server.withMethodHandler(ListTools.self) { _ in
            ListTools.Result(tools: tools())
        }
    }

    static func tools() -> [Tool] {
        []
    }
}
