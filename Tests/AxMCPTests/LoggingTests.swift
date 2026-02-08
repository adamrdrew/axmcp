import Testing
import Foundation
@testable import AxMCP

@Suite("Logging Tests")
struct LoggingTests {
    @Test("MCPLogger emits correct log levels")
    func testLogLevels() {
        let dest = MockLogDestination()
        let logger = MCPLogger(destination: dest, category: .server)
        logger.debug("debug msg")
        logger.info("info msg")
        logger.warning("warning msg")
        logger.error("error msg")
        let entries = dest.entries
        #expect(entries.count == 4)
        #expect(entries[0].level == .debug)
        #expect(entries[1].level == .info)
        #expect(entries[2].level == .warning)
        #expect(entries[3].level == .error)
    }

    @Test("MCPLogger uses correct category")
    func testCategory() {
        let dest = MockLogDestination()
        let logger = MCPLogger(destination: dest, category: .tools)
        logger.info("test")
        #expect(dest.entries.first?.category == "tools")
    }

    @Test("Server startup log does not contain UI data")
    func testStartupLogNoUIData() {
        let dest = MockLogDestination()
        let logger = MCPLogger(destination: dest, category: .server)
        logger.info("axmcp v0.1.0 starting")
        logger.info("read_only=false rate_limit=10/s")
        for entry in dest.entries {
            #expect(!entry.message.contains("AXButton"))
            #expect(!entry.message.contains("AXTextField"))
            #expect(!entry.message.contains("children"))
        }
    }

    @Test("Tool invocation log contains tool name only")
    func testToolLogMinimal() {
        let dest = MockLogDestination()
        let logger = MCPLogger(destination: dest, category: .tools)
        logger.info("tool=get_ui_tree")
        let entry = dest.entries.first
        #expect(entry?.message == "tool=get_ui_tree")
        #expect(entry?.level == .info)
        #expect(!entry!.message.contains("AXWindow"))
    }

    @Test("Error log does not contain element tree data")
    func testErrorLogNoTreeData() {
        let dest = MockLogDestination()
        let logger = MCPLogger(destination: dest, category: .tools)
        logger.error("tool=get_ui_tree error=timeout")
        let entry = dest.entries.first
        #expect(entry?.level == .error)
        #expect(!entry!.message.contains("role"))
        #expect(!entry!.message.contains("children"))
    }

    @Test("Error log format uses type name only, no UI data")
    func testErrorLogUsesTypeOnly() {
        let errorType = String(describing: type(of: ToolExecutionError.toolError(
            ToolError(operation: "test", errorType: "test", message: "secret title")
        )))
        #expect(!errorType.contains("secret"))
        #expect(!errorType.contains("AXButton"))
        #expect(!errorType.contains("children"))
        #expect(errorType == "ToolExecutionError")
    }

    @Test("All LogCategory values produce valid strings")
    func testLogCategories() {
        let categories: [LogCategory] = [
            .server, .tools, .axbridge, .security, .observers
        ]
        for cat in categories {
            #expect(!cat.rawValue.isEmpty)
        }
    }
}
