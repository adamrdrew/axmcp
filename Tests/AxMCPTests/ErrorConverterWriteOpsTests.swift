import Testing
import Foundation
@testable import AxMCP

@Suite("ErrorConverter Write Operations Tests")
struct ErrorConverterWriteOpsTests {
    @Test("Converts element path error")
    func testElementPathError() {
        let error = ElementPathError.emptyPath
        let result = ErrorConverter.convertElementPathError(
            error,
            operation: "perform_action",
            app: "Safari"
        )
        switch result {
        case .toolError(let toolError):
            #expect(toolError.operation == "perform_action")
            #expect(toolError.errorType == "element_path_error")
            #expect(toolError.app == "Safari")
            #expect(toolError.guidance != nil)
        }
    }

    @Test("Converts blocklist error")
    func testBlocklistError() {
        let error = BlocklistError.blockedApplication(
            appName: "Terminal",
            bundleID: "com.apple.Terminal"
        )
        let result = ErrorConverter.convertBlocklistError(
            error,
            operation: "set_value",
            app: "Terminal"
        )
        switch result {
        case .toolError(let toolError):
            #expect(toolError.operation == "set_value")
            #expect(toolError.errorType == "blocklisted_application")
            #expect(toolError.app == "Terminal")
            #expect(toolError.guidance != nil)
        }
    }

    @Test("Converts read-only error")
    func testReadOnlyError() {
        let result = ErrorConverter.convertReadOnlyError(
            operation: "perform_action"
        )
        switch result {
        case .toolError(let toolError):
            #expect(toolError.operation == "perform_action")
            #expect(toolError.errorType == "read_only_mode")
            #expect(toolError.guidance != nil)
        }
    }

    @Test("Converts action error")
    func testActionError() {
        let result = ErrorConverter.convertActionError(
            operation: "perform_action",
            action: "AXPress",
            app: "Safari"
        )
        switch result {
        case .toolError(let toolError):
            #expect(toolError.operation == "perform_action")
            #expect(toolError.errorType == "action_not_supported")
            #expect(toolError.app == "Safari")
            #expect(toolError.message.contains("AXPress"))
        }
    }

    @Test("All error conversions include required context")
    func testErrorContextFields() {
        let result = ErrorConverter.convertElementPathError(
            ElementPathError.emptyPath,
            operation: "perform_action",
            app: "Safari"
        )
        switch result {
        case .toolError(let toolError):
            #expect(!toolError.operation.isEmpty)
            #expect(!toolError.errorType.isEmpty)
            #expect(!toolError.message.isEmpty)
            #expect(toolError.app != nil)
        }
    }
}
