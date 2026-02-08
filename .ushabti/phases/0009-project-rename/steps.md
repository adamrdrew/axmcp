# Implementation Steps

## Step 1: Rename source directory

**Intent**: Move the main source code directory to the new name.

**Work**:
- Rename `Sources/AccessibilityMCP/` to `Sources/AxMCP/`
- Use `git mv` to preserve git history

**Done when**:
- Directory `Sources/AxMCP/` exists
- Directory `Sources/AccessibilityMCP/` no longer exists
- Git recognizes this as a rename, not delete + add

## Step 2: Rename test directory

**Intent**: Move the test directory to the new name.

**Work**:
- Rename `Tests/AccessibilityMCPTests/` to `Tests/AxMCPTests/`
- Use `git mv` to preserve git history

**Done when**:
- Directory `Tests/AxMCPTests/` exists
- Directory `Tests/AccessibilityMCPTests/` no longer exists
- Git recognizes this as a rename

## Step 3: Update Package.swift

**Intent**: Update the Swift package manifest to reflect new names.

**Work**:
- Change package name from `AccessibilityMCP` to `AxMCP`
- Change executable product name from `accessibility-mcp` to `axmcp`
- Change target name from `AccessibilityMCP` to `AxMCP`
- Change test target name from `AccessibilityMCPTests` to `AxMCPTests`
- Update target references in products and test dependencies

**Done when**:
- `Package.swift` declares `name: "AxMCP"`
- Executable product is `name: "axmcp"`
- Target is `name: "AxMCP"`
- Test target is `name: "AxMCPTests"`
- Package compiles with new configuration

## Step 4: Update all import statements in source files

**Intent**: Update Swift imports to use the new module name.

**Work**:
- Find all `.swift` files in `Sources/AxMCP/`
- Replace `import AccessibilityMCP` with `import AxMCP` (if any internal imports exist)
- Verify no cross-module imports reference old name

**Done when**:
- No source files contain `import AccessibilityMCP`
- All references use `import AxMCP` where applicable
- Code compiles without import errors

## Step 5: Update all import statements in test files

**Intent**: Update test imports to use the new module name.

**Work**:
- Find all `.swift` files in `Tests/AxMCPTests/`
- Replace `@testable import AccessibilityMCP` with `@testable import AxMCP`
- Replace any `import AccessibilityMCP` with `import AxMCP`

**Done when**:
- No test files contain `import AccessibilityMCP` or `@testable import AccessibilityMCP`
- All test imports reference `AxMCP`
- Tests compile without import errors

## Step 6: Update logging subsystem identifier

**Intent**: Change the os.log subsystem identifier to the new name.

**Work**:
- Find all instances of `com.adamrdrew.accessibility-mcp` in source files
- Replace with `com.adamrdrew.axmcp`
- Likely location: logging initialization, Logger declarations

**Done when**:
- No source files contain `com.adamrdrew.accessibility-mcp`
- All logging subsystem references use `com.adamrdrew.axmcp`
- Logs appear with new subsystem identifier when server runs

## Step 7: Update laws.md references

**Intent**: Update project laws to reference the new project name.

**Work**:
- Open `.ushabti/laws.md`
- Update preamble and any references from "Accessibility MCP server" to "AxMCP server"
- Update any code examples or references to module names

**Done when**:
- Laws preamble refers to "AxMCP server"
- No references to "Accessibility MCP" remain (except in historical context)
- Laws remain semantically unchanged (only name updates)

## Step 8: Update style.md references

**Intent**: Update project style guide to reference the new project name.

**Work**:
- Open `.ushabti/style.md`
- Update purpose section and references from "Accessibility MCP development" to "AxMCP development"
- Update directory structure examples to show `AxMCP/` instead of `AccessibilityMCP/`
- Update module boundary descriptions
- Update code examples showing imports or module names

**Done when**:
- Style guide refers to "AxMCP development"
- Directory structure examples show `AxMCP` module
- Code examples use `AxMCP` naming
- Style rules remain unchanged (only naming updates)

## Step 9: Update docs/index.md

**Intent**: Update documentation index to reflect the new project name.

**Work**:
- Open `.ushabti/docs/index.md`
- Update project name from "Accessibility MCP Server" to "AxMCP"
- Update description to use new name consistently

**Done when**:
- Project name field shows "AxMCP"
- Description uses "AxMCP" consistently
- Documentation remains accurate

## Step 10: Update README.md

**Intent**: Update main user-facing documentation to reflect the new project name.

**Work**:
- Open `README.md`
- Update title from "Accessibility MCP Server" to "AxMCP"
- Update all human-readable references to use "AxMCP"
- Update all binary path references from `accessibility-mcp` to `axmcp`
- Update repository URL references from `macos-accessibility-mcp` to new name (if changed, or mark as TBD)
- Update command examples (e.g., `brew install accessibility-mcp` → `brew install axmcp`)
- Update Claude Desktop config examples to show new binary name
- Update troubleshooting section references

**Done when**:
- README title is "AxMCP" (not "Accessibility MCP Server")
- Human-readable text consistently uses "AxMCP"
- Binary paths use `axmcp` (lowercase)
- Claude Desktop config examples show correct binary name
- No references to old name remain except in migration notes

## Step 11: Update CHANGELOG.md

**Intent**: Document the rename and update references to the new project name.

**Work**:
- Open `CHANGELOG.md`
- Add entry under `[Unreleased]` section documenting the rename
- Update header references from "Accessibility MCP" to "AxMCP" (for future entries)
- Preserve historical entries as-is (they document past state accurately)

**Done when**:
- Unreleased section includes entry: "Project renamed from Accessibility MCP to AxMCP"
- Future changelog sections will use "AxMCP" name
- Historical `[0.1.0]` entry remains unchanged (accurate for that release)
- Format remains Keep a Changelog compliant

## Step 12: Update GitHub Actions workflows

**Intent**: Update CI/CD workflows to reference the new binary name.

**Work**:
- Open `.github/workflows/*.yml` files
- Update any references to `accessibility-mcp` binary to `axmcp`
- Update artifact names, release asset names, or test commands
- Verify workflow syntax remains valid

**Done when**:
- Workflow files reference `axmcp` binary name
- Build and test steps use correct paths
- Release workflows (if any) publish with correct binary name
- Workflows remain syntactically valid YAML

## Step 13: Search and replace remaining references

**Intent**: Catch any remaining references to the old name in comments, strings, or documentation.

**Work**:
- Search entire codebase for case-insensitive "AccessibilityMCP" and "accessibility-mcp"
- Exclude `.build/` and `.git/` directories
- Update any remaining references in:
  - Swift file comments
  - String literals (if any reference project name)
  - Markdown files not yet updated
  - Configuration files
- Verify each match and update appropriately

**Done when**:
- Case-insensitive search for "AccessibilityMCP" returns only historical changelog entries and git metadata
- All code comments use "AxMCP"
- All user-facing strings use "AxMCP" or "axmcp" appropriately
- No orphaned references remain

## Step 14: Build and verify binary name

**Intent**: Verify the renamed project builds successfully and produces the correct binary.

**Work**:
- Run `swift build -c release`
- Verify binary is at `.build/release/axmcp` (not `accessibility-mcp`)
- Run the binary with `--help` or similar to ensure it executes
- Check that binary output/logs use new name

**Done when**:
- `swift build -c release` succeeds without errors
- Binary exists at `.build/release/axmcp`
- Binary executes successfully
- No references to old name appear in binary output

## Step 15: Run full test suite

**Intent**: Verify all tests pass with the renamed project.

**Work**:
- Run `swift test`
- Verify all 260+ tests pass
- Check for any test output referencing old name
- Fix any test failures related to naming

**Done when**:
- All tests pass (260+ tests)
- Test output references "AxMCP" where applicable
- No test failures due to rename
- Test suite runs without warnings

## Step 16: Verify no orphaned references

**Intent**: Final verification that all references have been updated.

**Work**:
- Run comprehensive search for old name variants:
  - `AccessibilityMCP`
  - `accessibility-mcp`
  - `Accessibility MCP`
- Exclude `.git/`, `.build/`, and historical changelog entries
- Verify all remaining matches are intentional (e.g., in old changelog entries)
- Document any intentional exceptions

**Done when**:
- Search returns only intentional matches (historical changelog, git history)
- No unintentional references to old name exist
- Code, docs, and configuration are fully updated
- Project is ready for release with new name
