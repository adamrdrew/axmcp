import MCP
import Foundation

extension ToolDispatcher {
    func handleWriteTool(
        name: String,
        data: Data,
        context: ServerContext
    ) async throws -> CallTool.Result {
        switch name {
        case "perform_action": return try await handlePerformAction(data: data, context: context)
        case "set_value": return try await handleSetValue(data: data, context: context)
        default: return CallTool.Result(content: [.text("Unknown tool")], isError: true)
        }
    }

    private func handlePerformAction(
        data: Data,
        context: ServerContext
    ) async throws -> CallTool.Result {
        let p = try JSONDecoder().decode(PerformActionParameters.self, from: data)
        let h = await createPerformActionHandler(context: context)
        let r = try await h.execute(parameters: p)
        return try encodeResult(r)
    }

    private func handleSetValue(
        data: Data,
        context: ServerContext
    ) async throws -> CallTool.Result {
        let p = try JSONDecoder().decode(SetValueParameters.self, from: data)
        let h = await createSetValueHandler(context: context)
        let r = try await h.execute(parameters: p)
        return try encodeResult(r)
    }

    private func createPerformActionHandler(
        context: ServerContext
    ) async -> PerformActionHandler {
        let config = await context.getConfiguration()
        let blocklist = await context.getBlocklist()
        let rateLimiter = await context.getRateLimiter()
        return PerformActionHandler(
            resolver: resolver, bridge: bridge,
            blocklist: blocklist, rateLimiter: rateLimiter, config: config
        )
    }

    private func createSetValueHandler(
        context: ServerContext
    ) async -> SetValueHandler {
        let config = await context.getConfiguration()
        let blocklist = await context.getBlocklist()
        let rateLimiter = await context.getRateLimiter()
        return SetValueHandler(
            resolver: resolver, bridge: bridge,
            blocklist: blocklist, rateLimiter: rateLimiter, config: config
        )
    }
}
