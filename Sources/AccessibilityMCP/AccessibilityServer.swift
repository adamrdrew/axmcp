import MCP
import Foundation

struct AccessibilityServer {
    static let name = "accessibility-mcp"
    static let version = "0.1.0"
    static let resolver = LiveAppResolver()
    static let bridge = LiveAXBridge()

    static func create() -> Server {
        Server(
            name: name,
            version: version,
            capabilities: .init(tools: .init())
        )
    }

    static func registerHandlers(
        on server: Server,
        context: ServerContext
    ) async {
        let config = await context.getConfiguration()
        await server.withMethodHandler(ListTools.self) { _ in
            ListTools.Result(tools: tools(config: config))
        }
        await server.withMethodHandler(CallTool.self) { params in
            try await callTool(params: params, context: context)
        }
    }

    static func tools(config: ServerConfiguration) -> [Tool] {
        var toolList = readTools()
        if !config.readOnlyMode {
            toolList.append(contentsOf: writeTools())
        }
        return toolList
    }

    private static func readTools() -> [Tool] {
        [
            Tool(
                name: "get_ui_tree",
                description: "Get accessibility tree for an app",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "app": .object([
                            "type": .string("string"),
                            "description": .string("App name or PID")
                        ]),
                        "depth": .object([
                            "type": .string("number"),
                            "description": .string("Max depth (default: 3)")
                        ])
                    ]),
                    "required": .array([.string("app")])
                ])
            ),
            Tool(
                name: "find_element",
                description: "Find elements matching criteria",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "app": .object([
                            "type": .string("string"),
                            "description": .string("App name or PID")
                        ]),
                        "role": .object([
                            "type": .string("string")
                        ]),
                        "title": .object([
                            "type": .string("string")
                        ])
                    ]),
                    "required": .array([.string("app")])
                ])
            ),
            Tool(
                name: "get_focused_element",
                description: "Get currently focused element",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:])
                ])
            ),
            Tool(
                name: "list_windows",
                description: "List windows",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:])
                ])
            )
        ]
    }

    private static func writeTools() -> [Tool] {
        [
            Tool(
                name: "perform_action",
                description: "Perform action on element",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "app": .object([
                            "type": .string("string"),
                            "description": .string("App name or PID")
                        ]),
                        "elementPath": .object([
                            "type": .string("string"),
                            "description": .string("Element path")
                        ]),
                        "action": .object([
                            "type": .string("string"),
                            "description": .string("Action name")
                        ])
                    ]),
                    "required": .array([.string("app"), .string("elementPath"), .string("action")])
                ])
            ),
            Tool(
                name: "set_value",
                description: "Set element value",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "app": .object([
                            "type": .string("string"),
                            "description": .string("App name or PID")
                        ]),
                        "elementPath": .object([
                            "type": .string("string"),
                            "description": .string("Element path")
                        ]),
                        "value": .object([
                            "description": .string("Value to set")
                        ])
                    ]),
                    "required": .array([.string("app"), .string("elementPath"), .string("value")])
                ])
            )
        ]
    }

    static func callTool(
        params: CallTool.Parameters,
        context: ServerContext
    ) async throws -> CallTool.Result {
        let resolver = LiveAppResolver()
        let bridge = LiveAXBridge()
        do {
            let data = try JSONEncoder().encode(params.arguments ?? [:])
            if params.name == "perform_action" || params.name == "set_value" {
                return try await handleWriteTool(
                    name: params.name,
                    data: data,
                    context: context
                )
            }
            switch params.name {
            case "get_ui_tree":
                let p = try JSONDecoder().decode(
                    GetUITreeParameters.self,
                    from: data
                )
                let h = GetUITreeHandler(resolver: resolver, bridge: bridge)
                let r = try h.execute(parameters: p)
                let responseData = try JSONEncoder().encode(r)
                let json = String(data: responseData, encoding: .utf8) ?? "{}"
                return CallTool.Result(content: [.text(json)])
            case "find_element":
                let p = try JSONDecoder().decode(
                    FindElementParameters.self,
                    from: data
                )
                let h = FindElementHandler(resolver: resolver, bridge: bridge)
                let r = try h.execute(parameters: p)
                let responseData = try JSONEncoder().encode(r)
                let json = String(data: responseData, encoding: .utf8) ?? "{}"
                return CallTool.Result(content: [.text(json)])
            case "get_focused_element":
                let p = try JSONDecoder().decode(
                    GetFocusedElementParameters.self,
                    from: data
                )
                let h = GetFocusedElementHandler(resolver: resolver, bridge: bridge)
                let r = try h.execute(parameters: p)
                let responseData = try JSONEncoder().encode(r)
                let json = String(data: responseData, encoding: .utf8) ?? "{}"
                return CallTool.Result(content: [.text(json)])
            case "list_windows":
                let p = try JSONDecoder().decode(
                    ListWindowsParameters.self,
                    from: data
                )
                let h = ListWindowsHandler(resolver: resolver, bridge: bridge)
                let r = try h.execute(parameters: p)
                let responseData = try JSONEncoder().encode(r)
                let json = String(data: responseData, encoding: .utf8) ?? "{}"
                return CallTool.Result(content: [.text(json)])
            default:
                return CallTool.Result(
                    content: [.text("Unknown tool")],
                    isError: true
                )
            }
        } catch {
            return CallTool.Result(
                content: [.text("Error: \(error)")],
                isError: true
            )
        }
    }
}
