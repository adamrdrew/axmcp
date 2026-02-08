# Phase 0007 — Polish & Harden

## Intent

Final hardening pass before v0.1.0 release. All features are implemented across phases 1-6 (skeleton, AX bridge, tree traversal, read-only tools, write tools & safety, observation). This phase focuses on production readiness: structured logging, error message quality, edge case resilience, complete documentation, and Homebrew distribution.

No new features are added. No tool interfaces change.

## Scope

### In scope

1. **Error message audit** — Review all error paths for clarity and actionability:
   - Permission denied: include System Settings navigation instructions
   - App not found: suggest similar running app names
   - Element path resolution failures: show expected vs. actual
   - Blocklist rejections: explain why and how to configure
   - Rate limit hits: explain current limit and how to adjust
   - Stale element references: explain why and suggest re-traversal

2. **Structured logging (os.log)** — Add unified logging across the server:
   - Info: server start, tool invocations, target app
   - Warning: rate limit hits, permission issues, TCC boundaries
   - Error: failures requiring attention
   - Debug: detailed diagnostics (disabled in release)
   - Enforce minimal result logging (L36) — no UI tree contents in production logs

3. **Edge case hardening** — Handle gracefully:
   - App quits between tool calls (L39 already exists; verify all paths)
   - UI changes between find_element and perform_action
   - Very large trees (>10,000 elements) — verify truncation/limits work
   - Apps with non-standard AX implementations
   - System sleep/wake during observation
   - Observer for app that immediately terminates

4. **Complete CHANGELOG.md** — Document all features from phases 1-6 under v0.1.0

5. **README.md polish** — Ensure completeness per L31:
   - Installation via Homebrew (tap + install)
   - Claude Desktop configuration JSON snippet
   - Permission setup instructions
   - All 7 tools documented with example inputs/outputs
   - Safety features and configuration reference
   - Troubleshooting common issues

6. **Homebrew distribution** — Release infrastructure:
   - GitHub Actions workflow for universal binary release (arm64 + x86_64)
   - Homebrew tap formula
   - Automated SHA256 and URL updates in formula on release

7. **Full test suite verification** — All tests green, no warnings

8. **Claude Desktop integration** — Verify end-to-end (manual, documented as acceptance criterion)

### Out of scope

- New MCP tools or features
- Changes to tool parameter schemas or response formats
- Performance optimization beyond edge case handling
- Integration test infrastructure changes

## Constraints

- L36 (Minimal Result Logging): No UI content in production logs
- L37 (Error Context Preservation): All errors must include context and guidance
- L39 (Graceful Application Termination): No crashes on app exit
- L30 (CHANGELOG Maintenance): Complete changelog for v0.1.0
- L31 (README Completeness): Full documentation
- L28 (Single Binary Output): Release must be single executable
- L29 (Semantic Versioning): v0.1.0 release tag
- All other laws remain enforced (no regressions)

## Acceptance criteria

1. All error messages include actionable guidance (audit documented in review)
2. Structured logging uses os.log with Info/Warning/Error/Debug levels
3. Production logs contain zero UI element data or tree content (L36)
4. Edge cases (app termination, stale refs, large trees) produce structured errors, not crashes
5. CHANGELOG.md documents all features from phases 1-6 under v0.1.0
6. README.md passes L31 completeness check (installation, config, permissions, all tools, safety, troubleshooting)
7. GitHub Actions workflow builds universal binary on release tag push
8. Homebrew tap formula installs and runs the server
9. All tests pass (`swift test` exits 0 with no warnings)
10. Claude Desktop can connect to the server and execute at least one read tool and one write tool

## Risks / notes

- Homebrew formula testing requires a GitHub release. Formula can be written and verified structurally but full `brew install` testing depends on a published release.
- Claude Desktop integration is manual verification — not automatable in CI.
- The os.log subsystem name should follow Apple conventions: `com.adamrdrew.accessibility-mcp`.
- Error message improvements are additive refinements to existing ErrorConverter patterns, not architectural changes.
