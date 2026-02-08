import MCP
import Foundation

extension AccessibilityServer {
    static func observeTools() -> [Tool] {
        [
            Tool(
                name: "observe_changes",
                description: "Watch for UI changes in an app",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "app": .object([
                            "type": .string("string"),
                            "description": .string("App name or PID")
                        ]),
                        "events": .object([
                            "type": .string("array"),
                            "description": .string("Event types: value_changed, focus_changed, window_created, window_destroyed, title_changed"),
                            "items": .object([
                                "type": .string("string")
                            ])
                        ]),
                        "element_path": .object([
                            "type": .string("string"),
                            "description": .string("Element path to observe")
                        ]),
                        "duration": .object([
                            "type": .string("number"),
                            "description": .string("Seconds to observe (default: 30, max: 300)")
                        ])
                    ]),
                    "required": .array([.string("app")])
                ])
            )
        ]
    }

    static func handleObserveTool(
        data: Data,
        context: ServerContext
    ) async throws -> CallTool.Result {
        let p = try JSONDecoder().decode(
            ObserveChangesParameters.self,
            from: data
        )
        let manager = await context.getObserverManager()
        let h = ObserveChangesHandler(
            resolver: resolver,
            bridge: bridge,
            observerManager: manager
        )
        let r = try await h.execute(parameters: p)
        let responseData = try JSONEncoder().encode(r)
        let json = String(data: responseData, encoding: .utf8) ?? "{}"
        return CallTool.Result(content: [.text(json)])
    }
}
