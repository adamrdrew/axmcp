import MCP
import Foundation

extension ToolDispatcher {
    func handleReadTool(
        name: String,
        data: Data,
        logger: MCPLogger
    ) throws -> CallTool.Result {
        switch name {
        case "get_ui_tree": return try handleGetUITree(data: data)
        case "find_element": return try handleFindElement(data: data)
        case "get_focused_element": return try handleGetFocusedElement(data: data)
        case "list_windows": return try handleListWindows(data: data)
        default: return unknownToolResult(name: name, logger: logger)
        }
    }

    private func handleGetUITree(data: Data) throws -> CallTool.Result {
        let p = try JSONDecoder().decode(GetUITreeParameters.self, from: data)
        let r = try GetUITreeHandler(resolver: resolver, bridge: bridge).execute(parameters: p)
        return try encodeResult(r)
    }

    private func handleFindElement(data: Data) throws -> CallTool.Result {
        let p = try JSONDecoder().decode(FindElementParameters.self, from: data)
        let r = try FindElementHandler(resolver: resolver, bridge: bridge).execute(parameters: p)
        return try encodeResult(r)
    }

    private func handleGetFocusedElement(data: Data) throws -> CallTool.Result {
        let p = try JSONDecoder().decode(GetFocusedElementParameters.self, from: data)
        let r = try GetFocusedElementHandler(resolver: resolver, bridge: bridge).execute(parameters: p)
        return try encodeResult(r)
    }

    private func handleListWindows(data: Data) throws -> CallTool.Result {
        let p = try JSONDecoder().decode(ListWindowsParameters.self, from: data)
        let r = try ListWindowsHandler(resolver: resolver, bridge: bridge).execute(parameters: p)
        return try encodeResult(r)
    }
}

extension ToolDispatcher {
    func encodeResult<R: Encodable>(_ result: R) throws -> CallTool.Result {
        let data = try JSONEncoder().encode(result)
        return CallTool.Result(content: [.text(String(data: data, encoding: .utf8) ?? "{}")])
    }

    func unknownToolResult(name: String, logger: MCPLogger) -> CallTool.Result {
        logger.error("unknown_tool=\(name)")
        return CallTool.Result(content: [.text("Unknown tool")], isError: true)
    }
}
