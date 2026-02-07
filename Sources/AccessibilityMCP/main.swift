import MCP

let server = AccessibilityServer.create()
await AccessibilityServer.registerHandlers(on: server)

let transport = StdioTransport()
try await server.start(transport: transport)
await server.waitUntilCompleted()
