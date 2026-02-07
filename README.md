# Accessibility MCP Server

A macOS MCP server written in Swift that exposes the macOS Accessibility (AX) API to LLMs through the Model Context Protocol.

## Status

This project is in early development. The current version (0.1.0) is a skeleton implementation that establishes the MCP server infrastructure without Accessibility-specific functionality.

## Requirements

- macOS 13.0 or later
- Swift 6

## Building

Build the project using Swift Package Manager:

```bash
swift build
```

## Running

Run the server from the build directory:

```bash
swift run accessibility-mcp
```

Or use the compiled binary:

```bash
.build/debug/accessibility-mcp
```

## Testing

Run the test suite:

```bash
swift test
```

## How It Works

This server uses the Model Context Protocol (MCP) to communicate with LLM clients like Claude Desktop over stdio transport. In future phases, it will provide structured access to any macOS application's UI through the Accessibility API.

## Development

This project uses the Ushabti iterative agile agentic development framework. See `.ushabti/` for phase plans and progress.

## License

TBD
