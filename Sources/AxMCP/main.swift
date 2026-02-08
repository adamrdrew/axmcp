import MCP

let config = ServerConfiguration.fromEnvironment()
let context = ServerContext(configuration: config)
let server = AccessibilityServer.create()

let logger = MCPLogger(
    destination: OSLogDestination(),
    category: .server
)
logger.info("axmcp v\(AccessibilityServer.version) starting")
logger.info("read_only=\(config.readOnlyMode) rate_limit=\(config.rateLimitPerSecond)/s")

await AccessibilityServer.registerHandlers(
    on: server, context: context, logger: logger
)

let transport = StdioTransport()
try await server.start(transport: transport)
await server.waitUntilCompleted()
