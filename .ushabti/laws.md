# Project Laws

## Preamble

These laws define the non-negotiable invariants for the Accessibility MCP server. Every implementation, refactor, and phase must satisfy these constraints. They are enforced during Overseer review and may not be weakened without explicit user authorization. A phase cannot be marked complete until all applicable laws are verified.

## Laws

### L01 — Swift 6 Language Level
- **Rule:** The project MUST use Swift 6 language mode with strict concurrency checking enabled.
- **Rationale:** Swift 6's strict concurrency model prevents data races and ensures memory safety in concurrent code. The Accessibility API requires thread-safe access patterns.
- **Enforcement:** Verify `.swift-version` file contains `6` and build settings specify Swift 6 language mode. Compilation must succeed with strict concurrency enabled.
- **Scope:** All Swift source files and build configurations.
- **Exceptions:** None.

### L02 — No Private APIs
- **Rule:** The project MUST use only public, documented macOS Accessibility APIs from ApplicationServices and other public system frameworks. No private or undocumented APIs are permitted.
- **Rationale:** Private APIs risk App Store rejection, breakage across macOS versions, and security audit failures.
- **Enforcement:** Review all framework imports. Verify all AX functions and types are documented in Apple's official Accessibility API documentation.
- **Scope:** All source files.
- **Exceptions:** None.

### L03 — No Escalated Privileges
- **Rule:** The server MUST NOT require root privileges, special entitlements beyond standard Accessibility entitlements, or attempt to escalate privileges at runtime.
- **Rationale:** Privilege escalation expands attack surface and creates security risks. The Accessibility API is designed to work within user-level permissions.
- **Enforcement:** Verify entitlements file contains only standard Accessibility declarations. Confirm no use of `Authorization` APIs, `sudo`, or privilege escalation mechanisms.
- **Scope:** All code and build configurations.
- **Exceptions:** None.

### L04 — Explicit Application Scope Required
- **Rule:** All element access operations MUST require explicit application scope (by PID, bundle identifier, or application name). System-wide unbounded element enumeration MUST NOT be exposed as a default operation.
- **Rationale:** Unbounded system-wide traversal can cause performance issues, privacy concerns, and overwhelming result sets. Explicit scoping forces intentional access patterns.
- **Enforcement:** Review all MCP tool definitions. Verify application scope is a required parameter or clearly scoped to focused element. System-wide element enumeration, if provided, must require explicit opt-in and depth limits.
- **Scope:** All MCP tools that access UI elements.
- **Exceptions:** Tools that query running applications list (not their UI elements) or get the currently focused element may use system-wide scope.

### L05 — Mandatory Tree Depth Limiting
- **Rule:** All UI tree traversal operations MUST enforce a maximum depth limit. The default depth limit MUST be documented and conservative (suggested: 10 levels). Depth limit MUST be a required parameter or enforced default.
- **Rationale:** Full AX trees for complex applications can be enormous (thousands of elements). Unbounded traversal causes performance issues and overwhelming output.
- **Enforcement:** Verify all tree traversal functions include depth limit logic. Confirm default limits are conservative. Test with complex applications (browsers, Xcode) to ensure limits prevent excessive output.
- **Scope:** All tree traversal and element query operations.
- **Exceptions:** Operations that access a single known element by direct reference without traversal.

### L06 — Element Reference Validation
- **Rule:** All element references received from MCP clients MUST be validated before use. Invalid or stale references MUST result in a structured error response, not a crash or undefined behavior.
- **Rationale:** AXUIElement references are ephemeral and can become invalid. External references may be malformed or malicious.
- **Enforcement:** Review all functions accepting element references. Verify validation logic checks element validity before attribute access or action execution. Test with intentionally invalid references.
- **Scope:** All functions accepting element identifiers or references as input.
- **Exceptions:** None.

### L07 — Accessibility Permission Detection and Handling
- **Rule:** The server MUST detect when Accessibility permissions are not granted and return a structured error with actionable guidance. The server MUST NOT attempt to bypass or circumvent permission requirements.
- **Rationale:** Accessibility permissions are required for AX API access. Clear error messaging prevents user confusion. Permission bypass attempts violate system security.
- **Enforcement:** Verify startup or first-access includes permission check using `AXIsProcessTrusted()`. Confirm error messages include guidance to System Settings > Privacy & Security > Accessibility. Test with permissions disabled.
- **Scope:** Server initialization and all AX API access points.
- **Exceptions:** None.

### L08 — Destructive Action Safeguards
- **Rule:** Actions that can cause data loss, destructive changes, or security implications (closing windows, deleting content, executing commands, modifying security settings) MUST be clearly documented as destructive. The server SHOULD support a read-only mode flag that disables all write operations.
- **Rationale:** Accessibility API access can drive any UI action. Accidental destructive actions carry real risk. Users need control over mutation capabilities.
- **Enforcement:** Review all action types. Verify destructive actions are documented. Confirm read-only mode flag exists and is tested. Verify read-only mode blocks all AXPerformAction and AXSetAttributeValue operations.
- **Scope:** All action execution and value-setting operations.
- **Exceptions:** None.

### L09 — Application Blocklist Support
- **Rule:** The server MUST support configurable application blocklists that prevent access to specified applications by bundle identifier. The blocklist SHOULD have a reasonable default set including security-sensitive applications (Keychain Access, System Settings privacy panes, password managers).
- **Rationale:** Some applications handle sensitive data that should not be exposed to LLM-driven automation by default.
- **Enforcement:** Verify configuration mechanism for blocklists. Confirm blocklist enforcement is tested. Review default blocklist for security-sensitive applications. Verify blocklist violations return clear error messages.
- **Scope:** All application access operations.
- **Exceptions:** Blocklist must be configurable (users can override defaults).

### L10 — Rate Limiting Enforcement
- **Rule:** The server MUST enforce rate limits on actions and potentially on expensive tree traversal operations to prevent runaway automation loops. Rate limits MUST be configurable.
- **Rationale:** Automation loops can cause UI thrashing, performance degradation, or unintended repeated actions.
- **Enforcement:** Verify rate limiting logic for action execution. Confirm rate limits are documented and configurable. Test that rate limit violations return structured errors.
- **Scope:** All action execution operations; optionally tree traversal.
- **Exceptions:** Read-only operations like getting single attribute values may have higher or no rate limits.

### L11 — Action Verification Support
- **Rule:** After executing an action, the server MUST support returning post-action element state or tree snapshot to allow verification of outcomes.
- **Rationale:** Actions may fail silently or have unexpected effects. Post-action state enables the LLM to verify success and handle failures.
- **Enforcement:** Review action execution responses. Verify they include post-action state (element attributes, tree snapshot, or explicit success indicator).
- **Scope:** All action execution operations.
- **Exceptions:** None.

### L12 — Structured JSON Responses Only
- **Rule:** All MCP tool responses MUST return structured JSON objects with consistent schemas. No raw strings, no unstructured output.
- **Rationale:** LLMs and MCP clients require structured, parseable output for reliable automation.
- **Enforcement:** Review all tool response construction. Verify JSON schema consistency. Test that responses are valid JSON.
- **Scope:** All MCP tool implementations.
- **Exceptions:** None.

### L13 — Mandatory Result Set Limits
- **Rule:** Operations that can return multiple elements (search, tree traversal) MUST enforce maximum result set sizes. Limits MUST be documented. Operations returning more than 100 elements SHOULD paginate or warn about truncation.
- **Rationale:** Unbounded result sets cause performance issues and overwhelming output.
- **Enforcement:** Verify all multi-element operations have result limits. Confirm limits are documented. Test with queries that would exceed limits.
- **Scope:** All operations returning collections of elements.
- **Exceptions:** None.

### L14 — ISO 8601 DateTime Format
- **Rule:** All datetime values in responses MUST use ISO 8601 format with timezone information.
- **Rationale:** ISO 8601 is unambiguous, sortable, and widely supported.
- **Enforcement:** Review all datetime serialization. Verify ISO 8601 compliance.
- **Scope:** All datetime values in MCP responses.
- **Exceptions:** None.

### L15 — Absolute Paths Only
- **Rule:** Any file paths in responses (e.g., from element attributes) MUST be absolute paths, never relative.
- **Rationale:** Relative paths are ambiguous without working directory context.
- **Enforcement:** Review all path handling. Verify resolution to absolute paths.
- **Scope:** All file path values in MCP responses.
- **Exceptions:** None.

### L16 — Read-Only vs. Write Operation Separation
- **Rule:** Read operations (tree traversal, attribute access, element search) and write operations (actions, value setting) MUST be clearly separated in API design. Write operations MUST be clearly identifiable as mutating.
- **Rationale:** Clear separation allows users to understand mutation boundaries and enables read-only mode enforcement.
- **Enforcement:** Review tool naming and categorization. Verify write operations are clearly marked. Confirm read-only mode logic can identify and block write operations.
- **Scope:** All MCP tool definitions and implementations.
- **Exceptions:** None.

### L17 — Operation Timeout Enforcement
- **Rule:** All operations that interact with the Accessibility API MUST enforce timeouts to prevent hanging on unresponsive applications or deadlocked UI states.
- **Rationale:** AX API calls can block indefinitely on unresponsive applications.
- **Enforcement:** Review all AX API interactions. Verify timeout logic. Test with unresponsive applications or blocked UI states.
- **Scope:** All AX API interactions.
- **Exceptions:** None.

### L18 — Result Limits Documented and Tested
- **Rule:** Every function that returns collections MUST document its maximum result size and enforce that limit. Tests MUST verify limit enforcement.
- **Rationale:** Prevents unbounded resource consumption.
- **Enforcement:** Review function documentation. Verify limit enforcement code. Confirm tests cover limit behavior.
- **Scope:** All functions returning collections.
- **Exceptions:** None.

### L19 — No Main Thread Blocking
- **Rule:** No operation MUST block the main thread. Long-running or potentially blocking operations MUST execute on background threads or dispatch queues.
- **Rationale:** Main thread blocking causes UI freezes and poor user experience in integrated scenarios.
- **Enforcement:** Review all operation implementations. Verify use of background queues for AX API calls. Test with slow or unresponsive target applications.
- **Scope:** All operation implementations.
- **Exceptions:** None.

### L20 — Actor-Based State Management
- **Rule:** All mutable state MUST be managed within Swift actors to ensure thread-safe access.
- **Rationale:** Swift 6 strict concurrency requires data race prevention. Actors provide isolation guarantees.
- **Enforcement:** Review all mutable state. Verify actor isolation. Confirm compilation with strict concurrency succeeds.
- **Scope:** All mutable state.
- **Exceptions:** None.

### L21 — Typed Throws
- **Rule:** All throwing functions MUST use typed throws with explicit error types. No untyped `throws`.
- **Rationale:** Typed throws enable exhaustive error handling and clearer error documentation.
- **Enforcement:** Review all function signatures. Verify typed throws usage. Confirm error types are defined and documented.
- **Scope:** All throwing functions.
- **Exceptions:** None.

### L22 — Swift Testing Framework
- **Rule:** The project MUST use Swift Testing framework for all tests, not XCTest.
- **Rationale:** Swift Testing provides modern, Swift-native testing with better async support and clearer syntax.
- **Enforcement:** Verify test files use `import Testing`. Confirm no XCTest imports. Review test package dependencies.
- **Scope:** All test code.
- **Exceptions:** None.

### L23 — Public Method Test Coverage
- **Rule:** Every public method MUST have at least one test that exercises its core functionality.
- **Rationale:** Untested code is unverified code. Public APIs are the contract with consumers.
- **Enforcement:** Review test suite. Map public methods to test coverage. Verify coverage reports show public API coverage.
- **Scope:** All public methods and functions.
- **Exceptions:** None.

### L24 — No Dead Code
- **Rule:** The codebase MUST NOT contain unreferenced functions, types, or variables. All code must be reachable.
- **Rationale:** Dead code increases maintenance burden and cognitive load.
- **Enforcement:** Use compiler warnings and static analysis. Review for unreferenced code during review.
- **Scope:** All source files.
- **Exceptions:** None.

### L25 — Test Independence and Idempotence
- **Rule:** Tests MUST be order-independent and repeatable. Tests MUST NOT depend on execution order or leave persistent state.
- **Rationale:** Test order dependencies cause flaky tests and debugging difficulty.
- **Enforcement:** Run tests in random order. Verify tests pass in isolation. Review for shared mutable state.
- **Scope:** All tests.
- **Exceptions:** None.

### L26 — No User Data Dependencies in Tests
- **Rule:** Tests MUST NOT depend on specific user applications, user data, or system state beyond standard macOS installations. Use mocks, fixtures, or test-specific applications.
- **Rationale:** User-dependent tests are not reproducible across environments.
- **Enforcement:** Review test setup. Verify use of mocks or fixtures. Confirm tests pass on clean macOS installations.
- **Scope:** Integration and unit tests.
- **Exceptions:** None.

### L27 — Mock AX API for Unit Tests
- **Rule:** Unit tests MUST use mocked or stubbed Accessibility API interfaces, not real system UI elements.
- **Rationale:** Real UI element tests are brittle, slow, and require specific system state.
- **Enforcement:** Review unit tests. Verify use of mocks or protocol-based stubs for AX API interactions.
- **Scope:** Unit tests.
- **Exceptions:** Integration tests may use real AX API with controlled test applications.

### L28 — Single Binary Output
- **Rule:** The build MUST produce a single statically-linked executable with no runtime dependencies beyond macOS system frameworks.
- **Rationale:** Simplifies distribution and ensures reliable deployment.
- **Enforcement:** Verify build output is single executable. Confirm no external dylib dependencies beyond system frameworks using `otool -L`.
- **Scope:** Build configuration and release artifacts.
- **Exceptions:** None.

### L29 — Semantic Versioning
- **Rule:** The project MUST follow semantic versioning (semver) for all releases.
- **Rationale:** Semver communicates compatibility expectations to users.
- **Enforcement:** Verify version numbers follow semver format. Review version bumps against change types.
- **Scope:** All releases and version tags.
- **Exceptions:** None.

### L30 — CHANGELOG Maintenance
- **Rule:** A CHANGELOG.md MUST be maintained and updated for every release, documenting changes in Keep a Changelog format.
- **Rationale:** Users need clear change documentation for upgrade decisions.
- **Enforcement:** Verify CHANGELOG.md exists and is updated with each release. Confirm format follows Keep a Changelog.
- **Scope:** All releases.
- **Exceptions:** None.

### L31 — README Completeness
- **Rule:** README.md MUST document installation, configuration, Accessibility permission setup, all MCP tools with examples, safety considerations, and troubleshooting.
- **Rationale:** Complete documentation enables users to successfully deploy and use the server.
- **Enforcement:** Review README for required sections. Verify all tools are documented. Confirm examples are accurate and runnable.
- **Scope:** README.md.
- **Exceptions:** None.

### L32 — Scribe Docs Consultation
- **Rule:** Scribe MUST consult `.ushabti/docs` when planning phases. Understanding documented systems is prerequisite to coherent planning.
- **Rationale:** Phase planning without system knowledge produces incoherent or conflicting plans.
- **Enforcement:** Overseer verifies Scribe referenced documentation when evaluating phase plans.
- **Scope:** All Scribe phase planning activities.
- **Exceptions:** None.

### L33 — Builder Docs Usage and Maintenance
- **Rule:** Builder MUST consult `.ushabti/docs` during implementation and MUST update docs when code changes affect documented systems. Docs are both a resource and a maintenance responsibility.
- **Rationale:** Docs inform implementation decisions. Stale docs mislead future work.
- **Enforcement:** Overseer verifies Builder consulted and updated docs during phase review.
- **Scope:** All Builder implementation activities.
- **Exceptions:** None.

### L34 — Overseer Docs Reconciliation
- **Rule:** Overseer MUST verify that `.ushabti/docs` are reconciled with code changes before declaring a phase complete. Stale docs are defects.
- **Rationale:** Docs must remain accurate to be useful. Reconciliation is a quality gate.
- **Enforcement:** Phase completion checklist includes docs reconciliation verification.
- **Scope:** All Overseer phase reviews.
- **Exceptions:** None.

### L35 — Phase Completion Requires Docs Reconciliation
- **Rule:** A phase cannot be marked GREEN/complete until documentation in `.ushabti/docs` is reconciled with the code work performed during that phase.
- **Rationale:** Phase completion implies all deliverables, including docs, are complete.
- **Enforcement:** Progress status cannot be set to GREEN until docs reconciliation is verified.
- **Scope:** All phases.
- **Exceptions:** None.

### L36 — Minimal Result Logging
- **Rule:** The server MUST NOT log element data, UI content, or operation results beyond what the MCP protocol requires for debugging. User UI data is potentially sensitive.
- **Rationale:** UI content may contain sensitive information. Excessive logging creates privacy and security risks.
- **Enforcement:** Review logging statements. Verify no element attributes, values, or content are logged outside debug modes. Confirm production logging is minimal.
- **Scope:** All logging code.
- **Exceptions:** Debug logging may include detailed output if explicitly enabled and documented as potentially exposing sensitive data.

### L37 — Error Context Preservation
- **Rule:** All errors returned to MCP clients MUST include sufficient context for diagnosis: operation attempted, element reference if applicable, underlying AX API error code if available, and actionable guidance when possible.
- **Rationale:** Opaque errors prevent users from understanding and resolving issues.
- **Enforcement:** Review error construction. Verify inclusion of context fields. Test error scenarios for clarity.
- **Scope:** All error responses.
- **Exceptions:** None.

### L38 — Element Attribute Type Safety
- **Rule:** Element attributes retrieved from the AX API MUST be type-checked and safely coerced. Type mismatches MUST result in structured errors, not crashes or undefined behavior.
- **Rationale:** AX API returns untyped CFTypeRef values. Type assumptions can fail and cause crashes.
- **Enforcement:** Review all attribute access code. Verify type checking and safe casting. Test with elements that have unexpected attribute types.
- **Scope:** All attribute retrieval operations.
- **Exceptions:** None.

### L39 — Graceful Application Termination Handling
- **Rule:** If a target application terminates during an operation, the server MUST detect this condition and return a structured error, not crash or hang.
- **Rationale:** Applications can quit at any time. The server must remain stable.
- **Enforcement:** Review operation error handling. Test scenarios where target application quits mid-operation.
- **Scope:** All operations targeting specific applications.
- **Exceptions:** None.

### L40 — Phase Scope Boundaries
- **Rule:** Phase 1 MUST be read-only (tree traversal, search, inspection). Phase 2 MUST add write operations (actions, value setting). Phase 3 MUST add observation (AXObserver). No write capabilities may be implemented in Phase 1.
- **Rationale:** Phased development ensures read capabilities are solid before adding mutation. Clear phase boundaries prevent scope creep.
- **Enforcement:** Overseer verifies phase scope matches these definitions. Phase 1 review confirms no action execution code exists.
- **Scope:** All phases in initial development.
- **Exceptions:** Phase boundaries may be adjusted with explicit user approval if justified.
