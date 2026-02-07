# Phase 0001: Skeleton — MCP Server with Stdio Transport

## Intent

Establish the foundational MCP server infrastructure. Create a compilable Swift package that integrates the Swift MCP SDK, implements stdio transport, successfully handshakes with MCP clients (like Claude Desktop), and returns an empty tool list. This proves the build system, dependency management, and MCP protocol integration work before any Accessibility-specific code is added.

This is the Accessibility MCP Server, a macOS MCP server that will expose the Accessibility (AX) API to LLMs. This phase establishes the project foundation — no Accessibility-specific code yet.

This project is a sibling to Spotlight MCP Server. It uses the same tech stack (Swift 6, SPM, Swift MCP SDK, stdio transport) and the same Ushabti methodology. The Spotlight MCP skeleton phase (0001) is a proven reference for this pattern.

## Scope

This phase MUST:
1. Create Package.swift with Swift 6 language mode, macOS 14+ deployment target, and the Swift MCP SDK dependency
2. Create the main entry point that starts the MCP server over stdio transport
3. Register zero tools (empty tool list)
4. Implement clean startup and shutdown
5. Compile and run successfully
6. Create initial README.md with project description and build instructions
7. Create initial CHANGELOG.md

This phase MUST NOT:
- Include any Accessibility API code
- Define any MCP tools
- Include any search, traversal, or UI interaction logic

## Constraints

### Laws
- **L01**: Swift 6 language mode with strict concurrency enabled
- **L21**: All throwing functions must use typed throws
- **L22**: Use Swift Testing framework (not XCTest)
- **L23**: Every public method must have at least one test
- **L28**: Build must produce single statically-linked executable
- **L29**: Follow semantic versioning (start at 0.1.0 for initial development)

### Style
- Swift Package Manager for build system
- stdio transport for MCP (standard for Claude Desktop)
- Swift MCP SDK as dependency
- Protocol-oriented programming for abstractions
- Actor-based state management for any mutable state
- Sandi Metz rules: ≤100 lines per type, ≤5 lines per method, ≤4 parameters
- Prefer immutability (let over var)
- No force-unwrapping in production code

## Acceptance Criteria

- `swift build` succeeds with zero warnings under Swift 6 strict concurrency
- The server binary starts, performs MCP handshake, and responds to tool list requests with an empty list
- README.md describes the project and how to build it
- CHANGELOG.md exists with initial version entry
- All laws are satisfied (verify against .ushabti/laws.md)
- All style conventions are followed (verify against .ushabti/style.md)

## Risks / Notes

- This phase intentionally contains no Accessibility-specific code. The goal is to prove the MCP integration works in isolation before adding domain complexity.
- The Swift MCP SDK is relatively new. If API surface changes, this phase establishes the integration pattern that later phases will build on.
- Stdio transport is synchronous by nature but MCP SDK may use async internally — ensure async/await is used correctly.
- No need for elaborate error handling yet — basic startup errors are sufficient for this phase.
