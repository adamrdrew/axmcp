import MCP
import Foundation

struct ToolDispatcher: Sendable {
    let resolver: any AppResolver
    let bridge: any AXBridge
    let logger: MCPLogger

    func dispatch(
        params: CallTool.Parameters,
        context: ServerContext
    ) async throws -> CallTool.Result {
        let toolLogger = MCPLogger(destination: logger.destination, category: .tools)
        toolLogger.info("tool=\(params.name)")
        do {
            return try await routeTool(params: params, context: context, logger: toolLogger)
        } catch {
            toolLogger.error("tool=\(params.name) error_type=\(type(of: error))")
            return CallTool.Result(content: [.text("Error: \(error)")], isError: true)
        }
    }
}

extension ToolDispatcher {
    private func routeTool(
        params: CallTool.Parameters,
        context: ServerContext,
        logger: MCPLogger
    ) async throws -> CallTool.Result {
        let data = try JSONEncoder().encode(params.arguments ?? [:])
        switch params.name {
        case "perform_action", "set_value":
            return try await handleWriteTool(name: params.name, data: data, context: context)
        case "observe_changes":
            return try await handleObserveTool(data: data, context: context)
        default:
            return try handleReadTool(name: params.name, data: data, logger: logger)
        }
    }
}
