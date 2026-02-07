# Steps for Phase 0001: Skeleton

## S001: Create Package Structure

**Intent:** Establish the Swift package with correct metadata and directory structure.

**Work:**
- Create Package.swift with:
  - Swift tools version 6.0
  - Package name: AccessibilityMCP
  - Executable product: accessibility-mcp
  - Swift 6 language mode
  - Swift MCP SDK dependency
  - Main module target (Sources/AccessibilityMCP/)
  - Test target (Tests/AccessibilityMCPTests/)
- Create .swift-version file containing `6`
- Create directory structure:
  - Sources/AccessibilityMCP/
  - Tests/AccessibilityMCPTests/

**Done when:**
- Package.swift exists with all required configuration
- .swift-version contains `6`
- Directory structure created
- `swift package resolve` succeeds (dependencies fetch)

---

## S002: Implement Server Entry Point

**Intent:** Create the main executable that starts the MCP server.

**Work:**
- Create Sources/AccessibilityMCP/main.swift
- Import Swift MCP SDK
- Set up async main entry point (@main attribute or top-level async)
- Initialize stdio transport
- Create server instance
- Start server with transport
- Handle basic errors with clear messages

**Done when:**
- main.swift exists and compiles
- Binary can be built with `swift build`
- Running binary starts without immediate crash
- Basic error output works (test by running binary)

---

## S003: Implement MCP Server Handler

**Intent:** Create the server handler that responds to MCP protocol requests.

**Work:**
- Create Sources/AccessibilityMCP/Server.swift
- Define server type conforming to Swift MCP SDK's server protocol
- Implement server info response:
  - Name: "accessibility-mcp"
  - Version: "0.1.0"
- Implement tool list handler returning empty array
- Ensure type is ≤100 lines (Sandi Metz rule)
- Use typed throws for any error-throwing functions

**Done when:**
- Server.swift exists and compiles
- Server responds to initialize request with info
- Server responds to tools/list with empty array
- Code follows Sandi Metz size constraints

---

## S004: Verify MCP Handshake

**Intent:** Ensure the server completes MCP handshake successfully with a real MCP client.

**Work:**
- Build release binary: `swift build -c release`
- Test handshake manually using stdio interaction or MCP test client
- Verify initialize request succeeds
- Verify tools/list returns empty array `[]`
- Verify server info includes correct name and version
- Document handshake test procedure in phase notes

**Done when:**
- Handshake completes successfully
- Server info response verified
- Empty tool list response verified
- No crashes or protocol errors during handshake

---

## S005: Add Basic Test Infrastructure

**Intent:** Establish test infrastructure and verify server initialization.

**Work:**
- Create Tests/AccessibilityMCPTests/ directory
- Create ServerTests.swift
- Import Testing framework (not XCTest)
- Write test for server initialization:
  - Verify server instance can be created
  - Verify server info is correctly set
- Ensure test passes with `swift test`
- Follow Swift Testing syntax (@Test, #expect)

**Done when:**
- ServerTests.swift exists
- At least one test exists using Swift Testing framework
- `swift test` runs and passes
- Test verifies server creation succeeds

---

## S006: Create Minimal README

**Intent:** Document the skeleton phase and provide basic usage instructions.

**Work:**
- Create README.md in project root
- Include:
  - Project name and description
  - Build instructions (`swift build`)
  - Run instructions (path to binary)
  - Note about early development status
  - Mention MCP server over stdio
  - Mention Swift 6 requirement
- Keep documentation minimal (comprehensive docs come later)

**Done when:**
- README.md exists
- Contains project name, description, build/run instructions
- Accurately describes current skeleton state
- Does not over-promise features not yet implemented

---

## S007: Create Initial CHANGELOG

**Intent:** Establish the project changelog to track version history from the start.

**Work:**
- Create CHANGELOG.md in project root
- Follow Keep a Changelog format (https://keepachangelog.com/)
- Add entry for version 0.1.0:
  - Mark as [Unreleased] or [0.1.0] with date if releasing
  - List under "Added" section:
    - Initial MCP server skeleton with stdio transport
    - Swift 6 language mode and strict concurrency
    - Empty tool list (MCP handshake working)
    - Basic test infrastructure using Swift Testing
- Include standard sections: Added, Changed, Deprecated, Removed, Fixed, Security

**Done when:**
- CHANGELOG.md exists in project root
- Contains entry for version 0.1.0 describing skeleton phase
- Follows Keep a Changelog format conventions
- Accurately reflects work completed in this phase
