import MCP
import Foundation

struct AccessibilityServer {
    static let name = "accessibility-mcp"
    static let version = "0.1.0"

    static func create() -> Server {
        Server(name: name, version: version, capabilities: .init(tools: .init()))
    }

    static func registerHandlers(
        on server: Server,
        context: ServerContext,
        logger: MCPLogger
    ) async {
        let dispatcher = createDispatcher(logger: logger)
        let config = await context.getConfiguration()
        await registerListTools(on: server, config: config)
        await registerCallTool(on: server, dispatcher: dispatcher, context: context)
    }
}

extension AccessibilityServer {
    private static func createDispatcher(logger: MCPLogger) -> ToolDispatcher {
        ToolDispatcher(resolver: LiveAppResolver(), bridge: LiveAXBridge(), logger: logger)
    }

    private static func registerListTools(
        on server: Server,
        config: ServerConfiguration
    ) async {
        await server.withMethodHandler(ListTools.self) { _ in
            ListTools.Result(tools: ToolRegistry.tools(config: config))
        }
    }

    private static func registerCallTool(
        on server: Server,
        dispatcher: ToolDispatcher,
        context: ServerContext
    ) async {
        await server.withMethodHandler(CallTool.self) { params in
            try await dispatcher.dispatch(params: params, context: context)
        }
    }
}
