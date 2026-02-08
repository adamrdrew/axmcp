import Testing
import Foundation
@testable import AxMCP

@Suite("ElementResolver Timeout Tests")
struct ElementResolverTimeoutTests {
    @Test("Resolver accepts paths with timeout")
    func acceptsPathsWithTimeout() throws {
        let resolver = ElementResolver()
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXApplication"
        let path = ElementPath(components: [.appByPID(1234)])
        let element = try resolver.resolve(
            path: path,
            bridge: bridge,
            timeout: 5.0
        )
        _ = element
    }

    @Test("Resolution with sufficient timeout succeeds")
    func sufficientTimeoutSucceeds() throws {
        let resolver = ElementResolver()
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXApplication"
        bridge.mockAttributes[.windows] = [UIElement]()
        let path = ElementPath(components: [.appByPID(1234)])
        let element = try resolver.resolve(
            path: path,
            bridge: bridge,
            timeout: 5.0
        )
        _ = element
    }

    @Test("Resolution exceeding timeout throws error")
    func timeoutExceededThrowsError() throws {
        let resolver = ElementResolver()
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXApplication"
        bridge.simulateSlowOperations = true
        bridge.operationDelay = 0.1
        var windows: [UIElement] = []
        for _ in 0..<5 {
            windows.append(bridge.createMockElement())
        }
        bridge.mockAttributes[.windows] = windows
        let path = ElementPath(components: [
            .appByPID(1234),
            .windowByIndex(0),
            .windowByIndex(1),
            .windowByIndex(2)
        ])
        #expect(performing: {
            try resolver.resolve(path: path, bridge: bridge, timeout: 0.01)
        }, throws: { error in
            if case ElementPathError.timeoutExceeded = error {
                return true
            }
            return false
        })
    }
}
