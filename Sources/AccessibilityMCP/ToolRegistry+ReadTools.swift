import MCP

extension ToolRegistry {
    static func getUITreeTool() -> Tool {
        Tool(
            name: "get_ui_tree",
            description: "Get accessibility tree for an app",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "app": .object(["type": .string("string"), "description": .string("App name or PID")]),
                    "depth": .object(["type": .string("number"), "description": .string("Max depth (default: 3)")])
                ]),
                "required": .array([.string("app")])
            ])
        )
    }

    static func findElementTool() -> Tool {
        Tool(
            name: "find_element",
            description: "Find elements matching criteria",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "app": .object(["type": .string("string"), "description": .string("App name or PID")]),
                    "role": .object(["type": .string("string")]),
                    "title": .object(["type": .string("string")])
                ]),
                "required": .array([.string("app")])
            ])
        )
    }

    static func getFocusedElementTool() -> Tool {
        Tool(
            name: "get_focused_element",
            description: "Get currently focused element",
            inputSchema: .object(["type": .string("object"), "properties": .object([:])])
        )
    }

    static func listWindowsTool() -> Tool {
        Tool(
            name: "list_windows",
            description: "List windows",
            inputSchema: .object(["type": .string("object"), "properties": .object([:])])
        )
    }
}
