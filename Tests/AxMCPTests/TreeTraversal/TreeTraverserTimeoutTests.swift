import Testing
import Foundation
@testable import AxMCP

@Suite("TreeTraverser Timeout Tests")
struct TreeTraverserTimeoutTests {
    @Test("Timeout configuration is accepted")
    func timeoutConfigurationAccepted() throws {
        let bridge = MockAXBridge()
        var mockBridge = bridge
        mockBridge.mockAttributes[.role] = "AXApplication"
        mockBridge.mockChildren = []
        let traverser = TreeTraverser()
        let options = TreeTraversalOptions(maxDepth: 5, timeout: 0.1)
        let element = try mockBridge.createApplicationElement(pid: 1234)
        let tree = try traverser.traverse(
            element: element,
            options: options,
            bridge: mockBridge,
            applicationPID: 1234
        )
        #expect(tree.role == "AXApplication")
    }

    @Test("Traversal with sufficient timeout succeeds")
    func sufficientTimeoutSucceeds() throws {
        var mockBridge = MockAXBridge()
        mockBridge.mockAttributes[.role] = "AXApplication"
        mockBridge.mockChildren = []
        let traverser = TreeTraverser()
        let options = TreeTraversalOptions(maxDepth: 5, timeout: 5.0)
        let element = try mockBridge.createApplicationElement(pid: 1234)
        let tree = try traverser.traverse(
            element: element,
            options: options,
            bridge: mockBridge,
            applicationPID: 1234
        )
        #expect(tree.role == "AXApplication")
    }

    @Test("Traversal exceeding timeout throws error")
    func timeoutExceededThrowsError() throws {
        var mockBridge = MockAXBridge()
        mockBridge.mockAttributes[.role] = "AXApplication"
        mockBridge.simulateSlowOperations = true
        mockBridge.operationDelay = 0.05
        var children: [UIElement] = []
        for _ in 0..<5 {
            children.append(mockBridge.createMockElement())
        }
        mockBridge.mockChildren = children
        let traverser = TreeTraverser()
        let options = TreeTraversalOptions(maxDepth: 10, timeout: 0.01)
        let element = try mockBridge.createApplicationElement(pid: 1234)
        #expect(performing: {
            try traverser.traverse(
                element: element,
                options: options,
                bridge: mockBridge,
                applicationPID: 1234
            )
        }, throws: { error in
            if case TreeTraversalError.timeoutExceeded = error {
                return true
            }
            return false
        })
    }
}
