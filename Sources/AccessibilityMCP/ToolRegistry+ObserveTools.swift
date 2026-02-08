import MCP

extension ToolRegistry {
    static func observeTools() -> [Tool] {
        [observeChangesTool()]
    }

    static func observeChangesTool() -> Tool {
        Tool(
            name: "observe_changes",
            description: "Watch for UI changes in an app",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "app": .object(["type": .string("string"), "description": .string("App name or PID")]),
                    "events": .object([
                        "type": .string("array"),
                        "description": .string("Event types: value_changed, focus_changed, window_created, window_destroyed, title_changed"),
                        "items": .object(["type": .string("string")])
                    ]),
                    "element_path": .object(["type": .string("string"), "description": .string("Element path to observe")]),
                    "duration": .object(["type": .string("number"), "description": .string("Seconds to observe (default: 30, max: 300)")])
                ]),
                "required": .array([.string("app")])
            ])
        )
    }
}
