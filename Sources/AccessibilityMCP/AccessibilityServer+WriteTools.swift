import MCP
import Foundation

extension AccessibilityServer {
    static func handleWriteTool(
        name: String,
        data: Data,
        context: ServerContext
    ) async throws -> CallTool.Result {
        let config = await context.getConfiguration()
        let blocklist = await context.getBlocklist()
        let rateLimiter = await context.getRateLimiter()
        switch name {
        case "perform_action":
            let p = try JSONDecoder().decode(
                PerformActionParameters.self,
                from: data
            )
            let h = PerformActionHandler(
                resolver: resolver,
                bridge: bridge,
                blocklist: blocklist,
                rateLimiter: rateLimiter,
                config: config
            )
            let r = try await h.execute(parameters: p)
            let responseData = try JSONEncoder().encode(r)
            let json = String(data: responseData, encoding: .utf8) ?? "{}"
            return CallTool.Result(content: [.text(json)])
        case "set_value":
            let p = try JSONDecoder().decode(
                SetValueParameters.self,
                from: data
            )
            let h = SetValueHandler(
                resolver: resolver,
                bridge: bridge,
                blocklist: blocklist,
                rateLimiter: rateLimiter,
                config: config
            )
            let r = try await h.execute(parameters: p)
            let responseData = try JSONEncoder().encode(r)
            let json = String(data: responseData, encoding: .utf8) ?? "{}"
            return CallTool.Result(content: [.text(json)])
        default:
            return CallTool.Result(
                content: [.text("Unknown tool")],
                isError: true
            )
        }
    }
}
