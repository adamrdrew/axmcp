import MCP

extension ToolRegistry {
    static func performActionTool() -> Tool {
        Tool(
            name: "perform_action",
            description: "Perform action on element",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "app": .object(["type": .string("string"), "description": .string("App name or PID")]),
                    "elementPath": .object(["type": .string("string"), "description": .string("Element path")]),
                    "action": .object(["type": .string("string"), "description": .string("Action name")])
                ]),
                "required": .array([.string("app"), .string("elementPath"), .string("action")])
            ])
        )
    }

    static func setValueTool() -> Tool {
        Tool(
            name: "set_value",
            description: "Set element value",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "app": .object(["type": .string("string"), "description": .string("App name or PID")]),
                    "elementPath": .object(["type": .string("string"), "description": .string("Element path")]),
                    "value": .object(["description": .string("Value to set")])
                ]),
                "required": .array([.string("app"), .string("elementPath"), .string("value")])
            ])
        )
    }
}
