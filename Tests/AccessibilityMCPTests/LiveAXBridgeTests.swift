import Testing
@testable import AccessibilityMCP

@Suite("AXBridge Tests")
struct LiveAXBridgeTests {
    @Test("getAttribute returns expected type")
    func getAttributeReturnsExpectedType() async throws {
        var mock = MockAXBridge()
        mock.mockAttributes[.title] = "Test Title"

        let element = try mock.createSystemWideElement()
        let title: String = try mock.getAttribute(.title, from: element)

        #expect(title == "Test Title")
    }

    @Test("getAttribute with type mismatch throws error")
    func getAttributeTypeMismatch() async throws {
        var mock = MockAXBridge()
        mock.mockAttributes[.title] = "Test Title"

        let element = try mock.createSystemWideElement()

        #expect(
            throws: AccessibilityError.self,
            performing: {
                let _: Int = try mock.getAttribute(.title, from: element)
            }
        )
    }

    @Test("getAttribute with missing attribute throws error")
    func getAttributeNotFound() async throws {
        let mock = MockAXBridge()
        let element = try mock.createSystemWideElement()

        #expect(
            throws: AccessibilityError.self,
            performing: {
                let _: String = try mock.getAttribute(.title, from: element)
            }
        )
    }

    @Test("getAttributeNames returns array of attributes")
    func getAttributeNames() async throws {
        var mock = MockAXBridge()
        mock.mockAttributes[.title] = "Test"
        mock.mockAttributes[.role] = "Button"

        let element = try mock.createSystemWideElement()
        let names = try mock.getAttributeNames(from: element)

        #expect(names.contains(.title))
        #expect(names.contains(.role))
    }

    @Test("createApplicationElement returns UIElement")
    func createApplicationElement() async throws {
        let mock = MockAXBridge()
        _ = try mock.createApplicationElement(pid: 1)
    }

    @Test("createSystemWideElement returns UIElement")
    func createSystemWideElement() async throws {
        let mock = MockAXBridge()
        _ = try mock.createSystemWideElement()
    }

    @Test("createApplicationElement with permission denied throws error")
    func createApplicationElementPermissionDenied() async throws {
        var mock = MockAXBridge()
        mock.shouldThrowPermissionDenied = true

        #expect(
            throws: AccessibilityError.self,
            performing: {
                let _ = try mock.createApplicationElement(pid: 1)
            }
        )
    }

    @Test("getChildren returns array of UIElement")
    func getChildrenReturnsArray() async throws {
        var mock = MockAXBridge()
        let child1 = try mock.createSystemWideElement()
        let child2 = try mock.createSystemWideElement()
        mock.mockChildren = [child1, child2]

        let element = try mock.createSystemWideElement()
        let children = try mock.getChildren(from: element)

        #expect(children.count == 2)
    }

    @Test("getChildren with no children returns empty array")
    func getChildrenEmpty() async throws {
        let mock = MockAXBridge()
        let element = try mock.createSystemWideElement()
        let children = try mock.getChildren(from: element)

        #expect(children.isEmpty)
    }
}
