import Testing
import Foundation
import ApplicationServices
@testable import AccessibilityMCP

@Suite("ElementResolver Failure Tests")
struct ElementResolverFailureTests {
    @Test("Resolver fails on non-existent window index")
    func failsOnNonExistentWindowIndex() {
        let resolver = ElementResolver()
        let bridge = createBridgeWithWindows()
        let path = ElementPath(components: [
            .appByPID(1234),
            .windowByIndex(99)
        ])
        #expect(throws: ElementPathError.self) {
            try resolver.resolve(path: path, bridge: bridge)
        }
    }

    @Test("Resolver fails on non-existent window title")
    func failsOnNonExistentWindowTitle() {
        let resolver = ElementResolver()
        let bridge = createBridgeWithWindows()
        let path = ElementPath(components: [
            .appByPID(1234),
            .windowByTitle("NonExistent")
        ])
        #expect(throws: ElementPathError.self) {
            try resolver.resolve(path: path, bridge: bridge)
        }
    }

    @Test("Error includes available window titles")
    func errorIncludesAvailableTitles() {
        let resolver = ElementResolver()
        var bridge = createBridgeWithWindows()
        let path = ElementPath(components: [
            .appByPID(1234),
            .windowByTitle("NonExistent")
        ])
        do {
            _ = try resolver.resolve(path: path, bridge: bridge)
            Issue.record("Expected error to be thrown")
        } catch let error as ElementPathError {
            if case .componentNotFound(_, let available) = error {
                #expect(!available.isEmpty)
            } else {
                Issue.record("Wrong error type")
            }
        } catch {
            Issue.record("Wrong error type")
        }
    }

    private func createBridgeWithWindows() -> MockAXBridge {
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXApplication"
        let window1 = UIElement(AXUIElementCreateSystemWide())
        let window2 = UIElement(AXUIElementCreateSystemWide())
        bridge.mockAttributes[.windows] = [window1, window2]
        bridge.mockAttributes[.title] = "Document1"
        return bridge
    }
}
