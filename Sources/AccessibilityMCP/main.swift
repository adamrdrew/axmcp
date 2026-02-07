import MCP

let config = ServerConfiguration.fromEnvironment()
let context = ServerContext(configuration: config)
let server = AccessibilityServer.create()
await AccessibilityServer.registerHandlers(on: server, context: context)

let transport = StdioTransport()
try await server.start(transport: transport)
await server.waitUntilCompleted()
