# Phase 9: Project Rename to AxMCP

## Intent

Rename the project from "Accessibility MCP" / "accessibility-mcp" to the more concise "AxMCP" / "axmcp" throughout all code, documentation, configuration, and artifacts. The old name "accessibility mcp" is clunky and verbose. The new name "AxMCP" is shorter, more memorable, and maintains clear recognition of its purpose (Accessibility + MCP).

This is a pure rename operation with no functionality changes. All symbols, module names, file paths, directory names, documentation references, and configuration artifacts must reflect the new name consistently.

## Scope

**In scope:**

- Update `Package.swift` to rename:
  - Package name: `AccessibilityMCP` → `AxMCP`
  - Executable product name: `accessibility-mcp` → `axmcp`
  - Target name: `AccessibilityMCP` → `AxMCP`
  - Test target name: `AccessibilityMCPTests` → `AxMCPTests`
- Rename source directory: `Sources/AccessibilityMCP/` → `Sources/AxMCP/`
- Rename test directory: `Tests/AccessibilityMCPTests/` → `Tests/AxMCPTests/`
- Update all Swift imports: `import AccessibilityMCP` → `import AxMCP`
- Update all `@testable import` statements: `@testable import AccessibilityMCP` → `@testable import AxMCP`
- Update all file headers/copyright comments that reference "AccessibilityMCP" → "AxMCP"
- Update human-readable references in documentation files:
  - `README.md`: "Accessibility MCP Server" → "AxMCP"
  - `CHANGELOG.md`: "Accessibility MCP" → "AxMCP"
  - `.ushabti/docs/index.md`: "Accessibility MCP Server" → "AxMCP"
  - Laws preamble: "Accessibility MCP server" → "AxMCP server"
  - Style guide: "Accessibility MCP development" → "AxMCP development"
- Update binary path references in documentation (e.g., `.build/release/accessibility-mcp` → `.build/release/axmcp`)
- Update logging subsystem identifier: `com.adamrdrew.accessibility-mcp` → `com.adamrdrew.axmcp`
- Update GitHub Actions workflow references to binary name
- Update any hardcoded strings or comments referencing the old name
- Update Homebrew formula references if present in documentation
- Update `.ushabti/laws.md` and `.ushabti/style.md` references

**Out of scope:**

- Git repository URL changes (handled separately by repository owner)
- GitHub repository name changes (handled separately by repository owner)
- Homebrew tap name changes (handled separately by maintainer)
- GitHub release tag format changes (semantic versioning remains unchanged)
- Any functionality changes, refactoring, or feature additions
- Changes to MCP protocol tool names (they remain lowercase and descriptive as per MCP conventions)
- Changes to test behavior, assertions, or coverage

## Constraints

**Relevant laws:**

- **L24**: No dead code — ensure all references are updated and no orphaned references remain
- **L23**: Public method test coverage — all tests must pass after rename
- **L22**: Swift Testing framework — continue using Swift Testing (no framework changes)
- **L30**: CHANGELOG maintenance — document the rename in CHANGELOG.md
- **L31**: README completeness — ensure README remains complete and accurate after rename
- **L33**: Builder docs usage and maintenance — update docs to reflect new name
- **L35**: Phase completion requires docs reconciliation — all docs must be reconciled before completion

**Relevant style:**

- **Naming conventions**: Code identifiers lowercase `axmcp`, human-readable text `AxMCP`
- **File organization**: Maintain existing file structure, only rename directories
- **Module boundaries**: Preserve existing module structure with new names
- **Import statements**: Update all import statements consistently

**Naming rules (critical):**

- **Code identifiers** (module names, directory names, package names, executable names, import statements): `axmcp` or `AxMCP` (use existing case convention)
- **Human-readable text** (docs, comments, README, CHANGELOG, UI strings): `AxMCP`
- **File paths and command-line references**: `axmcp` (lowercase)
- **Logging identifiers**: `axmcp` (lowercase)

## Acceptance Criteria

1. `Package.swift` declares package name as `AxMCP`, executable as `axmcp`, target as `AxMCP`, test target as `AxMCPTests`
2. Source directory is `Sources/AxMCP/`
3. Test directory is `Tests/AxMCPTests/`
4. All Swift files import `AxMCP` (not `AccessibilityMCP`)
5. All test files use `@testable import AxMCP`
6. Binary name is `axmcp` (verify `.build/release/axmcp` exists after build)
7. Logging subsystem is `com.adamrdrew.axmcp`
8. README.md refers to "AxMCP" in human-readable text, `axmcp` in code/paths
9. CHANGELOG.md documents the rename and uses "AxMCP" consistently
10. Laws and style files refer to "AxMCP server" or "AxMCP development"
11. `.ushabti/docs/index.md` uses "AxMCP" as project name
12. All tests pass (`swift test` succeeds with 260+ tests passing)
13. Project builds successfully (`swift build -c release` succeeds)
14. No references to "AccessibilityMCP" or "accessibility-mcp" remain except in git history and CHANGELOG historical entries
15. GitHub Actions workflows reference correct binary name `axmcp`

## Risks / Notes

**Known tradeoffs:**

- Git repository URL and GitHub repository name are intentionally out of scope. Users with existing clones may need to update their remote URLs manually if those are changed separately.
- Homebrew formula will need separate update after repository rename (if repository is renamed).
- Existing Claude Desktop configurations will need manual update to new binary path.

**Intentionally deferred:**

- Repository URL/name changes (requires GitHub repository settings changes outside of code)
- Homebrew tap updates (requires separate PR to tap repository)
- Notification to users about configuration changes (handled via release notes and documentation updates in this phase)

**Migration guidance for users:**

Users will need to update their `claude_desktop_config.json` binary path from `accessibility-mcp` to `axmcp`. This will be documented in CHANGELOG and README.
