import MCP
import Foundation

extension ToolDispatcher {
    func handleObserveTool(
        data: Data,
        context: ServerContext
    ) async throws -> CallTool.Result {
        let p = try JSONDecoder().decode(ObserveChangesParameters.self, from: data)
        let manager = await context.getObserverManager()
        let h = ObserveChangesHandler(resolver: resolver, bridge: bridge, observerManager: manager)
        let r = try await h.execute(parameters: p)
        return try encodeResult(r)
    }
}
