import MCP

struct ToolRegistry: Sendable {
    static func tools(config: ServerConfiguration) -> [Tool] {
        var list = readTools()
        list.append(contentsOf: observeTools())
        if !config.readOnlyMode { list.append(contentsOf: writeTools()) }
        return list
    }

    static func readTools() -> [Tool] {
        [getUITreeTool(), findElementTool(), getFocusedElementTool(), listWindowsTool()]
    }

    static func writeTools() -> [Tool] {
        [performActionTool(), setValueTool()]
    }
}
