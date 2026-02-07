import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("ElementResolver Tests")
struct ElementResolverTests {
    @Test("Resolver rejects invalid PID")
    func rejectsInvalidPID() {
        let resolver = ElementResolver()
        let bridge = MockAXBridge()
        let path = ElementPath(components: [.appByPID(-1)])
        #expect(throws: ElementPathError.self) {
            try resolver.resolve(path: path, bridge: bridge)
        }
    }

    @Test("Resolver rejects empty path")
    func rejectsEmptyPath() {
        let resolver = ElementResolver()
        let bridge = MockAXBridge()
        let path = ElementPath(components: [])
        #expect(throws: ElementPathError.emptyPath) {
            try resolver.resolve(path: path, bridge: bridge)
        }
    }

    @Test("Resolver rejects excessively long path")
    func rejectsLongPath() {
        let resolver = ElementResolver()
        let bridge = MockAXBridge()
        let components = Array(repeating: ElementPathComponent.windowByIndex(0), count: 100)
        let path = ElementPath(components: components)
        #expect(throws: ElementPathError.self) {
            try resolver.resolve(path: path, bridge: bridge)
        }
    }
}
