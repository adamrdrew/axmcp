import Testing
import Foundation
import ApplicationServices
@testable import AxMCP

@Suite("ElementResolver Success Tests")
struct ElementResolverSuccessTests {
    @Test("Resolver resolves app by PID")
    func resolvesAppByPID() throws {
        let resolver = ElementResolver()
        var bridge = MockAXBridge()
        bridge.mockAttributes[.role] = "AXApplication"
        let path = ElementPath(components: [.appByPID(1234)])
        let element = try resolver.resolve(path: path, bridge: bridge)
        #expect(element.rawElement != nil)
    }

    @Test("Resolver resolves window by index")
    func resolvesWindowByIndex() throws {
        let resolver = ElementResolver()
        var bridge = createBridgeWithWindows()
        let path = ElementPath(components: [
            .appByPID(1234),
            .windowByIndex(0)
        ])
        let element = try resolver.resolve(path: path, bridge: bridge)
        #expect(element.rawElement != nil)
    }

    @Test("Resolver resolves window by title")
    func resolvesWindowByTitle() throws {
        let resolver = ElementResolver()
        var bridge = createBridgeWithWindows()
        let path = ElementPath(components: [
            .appByPID(1234),
            .windowByTitle("Document1")
        ])
        let element = try resolver.resolve(path: path, bridge: bridge)
        #expect(element.rawElement != nil)
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
