import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("Error Guidance Tests")
struct ErrorGuidanceTests {
    private func extractToolError(
        _ exec: ToolExecutionError
    ) -> ToolError {
        switch exec {
        case .toolError(let te): return te
        }
    }

    @Test("Permission denied includes System Settings path")
    func testPermissionDeniedGuidance() {
        let err = ErrorConverter.convertAccessibilityError(
            .permissionDenied(guidance: "Open System Settings > Privacy & Security > Accessibility and enable this application. You may need to restart after granting permission."),
            operation: "get_ui_tree",
            app: "Finder"
        )
        let te = extractToolError(err)
        #expect(te.guidance?.contains("System Settings") == true)
        #expect(te.guidance?.contains("Accessibility") == true)
    }

    @Test("App not running includes launch suggestion")
    func testAppNotRunningGuidance() {
        let err = ErrorConverter.convertAppError(
            .notRunning(appName: "MyApp"),
            operation: "get_ui_tree"
        )
        let te = extractToolError(err)
        #expect(te.guidance?.contains("Start the application") == true)
    }

    @Test("Multiple matches includes app names")
    func testMultipleMatchesGuidance() {
        let err = ErrorConverter.convertAppError(
            .multipleMatches(appName: "App", matches: ["App1", "App2"]),
            operation: "get_ui_tree"
        )
        let te = extractToolError(err)
        #expect(te.guidance?.contains("App1") == true)
        #expect(te.guidance?.contains("App2") == true)
    }

    @Test("Blocklist error includes bundle ID and env var")
    func testBlocklistGuidance() {
        let err = ErrorConverter.convertBlocklistError(
            .blockedApplication(
                appName: "Terminal",
                bundleID: "com.apple.Terminal"
            ),
            operation: "perform_action",
            app: "Terminal"
        )
        let te = extractToolError(err)
        #expect(te.guidance?.contains("com.apple.Terminal") == true)
        #expect(te.guidance?.contains("ACCESSIBILITY_MCP_BLOCKLIST") == true)
    }

    @Test("Read-only mode error includes env var name")
    func testReadOnlyGuidance() {
        let err = ErrorConverter.convertReadOnlyError(
            operation: "perform_action"
        )
        let te = extractToolError(err)
        #expect(te.guidance?.contains("--read-only") == true)
        #expect(te.guidance?.contains("ACCESSIBILITY_MCP_READ_ONLY") == true)
    }

    @Test("Stale reference includes re-traversal suggestion")
    func testStaleReferenceGuidance() {
        let path = ElementPath(components: [.appByPID(1234)])
        let err = ErrorConverter.convertElementPathError(
            .staleReference(path),
            operation: "perform_action",
            app: "Finder"
        )
        let te = extractToolError(err)
        #expect(te.guidance?.contains("get_ui_tree") == true)
    }

    @Test("Element not found includes re-traversal suggestion")
    func testElementNotFoundGuidance() {
        let path = ElementPath(components: [.appByPID(1234)])
        let err = ErrorConverter.convertElementPathError(
            .elementNotFound(path),
            operation: "set_value",
            app: "Finder"
        )
        let te = extractToolError(err)
        #expect(te.guidance?.contains("find_element") == true)
    }

    @Test("Invalid element error suggests re-traversal")
    func testInvalidElementGuidance() {
        let err = ErrorConverter.convertAccessibilityError(
            .invalidUIElement,
            operation: "perform_action",
            app: "Finder"
        )
        let te = extractToolError(err)
        #expect(te.guidance?.contains("get_ui_tree") == true)
    }

    @Test("Timeout error suggests reducing depth")
    func testTimeoutGuidance() {
        let err = ErrorConverter.convertTraversalError(
            .timeoutExceeded(5.0),
            operation: "get_ui_tree",
            app: "Xcode",
            guidance: ""
        )
        let te = extractToolError(err)
        #expect(te.guidance?.contains("depth") == true)
    }

    @Test("Observer creation failed includes permission hint")
    func testObserverCreationGuidance() {
        let err = ErrorConverter.convertObserverError(
            .observerCreationFailed("AXObserver error"),
            operation: "observe_changes",
            app: "Finder"
        )
        let te = extractToolError(err)
        #expect(te.guidance?.contains("System Settings") == true)
    }

    @Test("Action not supported includes actions hint")
    func testActionNotSupportedGuidance() {
        let err = ErrorConverter.convertActionError(
            operation: "perform_action",
            action: "AXPress",
            app: "Finder"
        )
        let te = extractToolError(err)
        #expect(te.guidance?.contains("actions") == true)
    }

    @Test("All error types have non-nil guidance")
    func testAllErrorsHaveGuidance() {
        let path = ElementPath(components: [.appByPID(1234)])
        let errors: [ToolExecutionError] = [
            ErrorConverter.convertAppError(
                .notRunning(appName: "X"), operation: "test"
            ),
            ErrorConverter.convertAppError(
                .multipleMatches(appName: "X", matches: ["A"]),
                operation: "test"
            ),
            ErrorConverter.convertAppError(
                .invalidIdentifier(identifier: "???"),
                operation: "test"
            ),
            ErrorConverter.convertAccessibilityError(
                .permissionDenied(guidance: "Grant access"),
                operation: "test", app: nil
            ),
            ErrorConverter.convertAccessibilityError(
                .invalidUIElement, operation: "test", app: nil
            ),
            ErrorConverter.convertAccessibilityError(
                .cannotComplete, operation: "test", app: nil
            ),
            ErrorConverter.convertElementPathError(
                .staleReference(path), operation: "test", app: "X"
            ),
            ErrorConverter.convertElementPathError(
                .elementNotFound(path), operation: "test", app: "X"
            ),
            ErrorConverter.convertBlocklistError(
                .blockedApplication(appName: "X", bundleID: "com.x"),
                operation: "test", app: "X"
            ),
            ErrorConverter.convertReadOnlyError(operation: "test"),
            ErrorConverter.convertActionError(
                operation: "test", action: "AXPress", app: "X"
            ),
            ErrorConverter.convertObserverError(
                .observerCreationFailed("err"),
                operation: "test", app: "X"
            ),
            ErrorConverter.convertObserverError(
                .applicationTerminated(pid: 1),
                operation: "test", app: "X"
            ),
        ]
        for err in errors {
            let te = extractToolError(err)
            #expect(
                te.guidance != nil,
                "Missing guidance for \(te.errorType)"
            )
            #expect(
                !te.guidance!.isEmpty,
                "Empty guidance for \(te.errorType)"
            )
        }
    }
}
