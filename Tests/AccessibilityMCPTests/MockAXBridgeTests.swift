import Testing
@testable import AccessibilityMCP

@Suite("MockAXBridge Tests")
struct MockAXBridgeTests {
    @Test("Mock returns configured attributes")
    func mockReturnsConfiguredAttributes() async throws {
        var mock = MockAXBridge()
        mock.mockAttributes[.title] = "Mock Title"
        mock.mockAttributes[.role] = "Mock Role"

        let element = try mock.createSystemWideElement()
        let title: String = try mock.getAttribute(.title, from: element)
        let role: String = try mock.getAttribute(.role, from: element)

        #expect(title == "Mock Title")
        #expect(role == "Mock Role")
    }

    @Test("Mock returns configured children")
    func mockReturnsConfiguredChildren() async throws {
        var mock = MockAXBridge()
        let child1 = try mock.createSystemWideElement()
        let child2 = try mock.createSystemWideElement()
        mock.mockChildren = [child1, child2]

        let element = try mock.createSystemWideElement()
        let children = try mock.getChildren(from: element)

        #expect(children.count == 2)
    }

    @Test("Mock returns configured actions")
    func mockReturnsConfiguredActions() async throws {
        var mock = MockAXBridge()
        mock.mockActions = [.press, .pick]

        let element = try mock.createSystemWideElement()
        let actions = try mock.getActionNames(from: element)

        #expect(actions.contains(.press))
        #expect(actions.contains(.pick))
        #expect(actions.count == 2)
    }

    @Test("Mock can simulate permission denied error")
    func mockSimulatesPermissionDenied() async throws {
        var mock = MockAXBridge()
        mock.shouldThrowPermissionDenied = true

        #expect(
            throws: AccessibilityError.self,
            performing: {
                let _ = try mock.createSystemWideElement()
            }
        )
    }

    @Test("Mock can simulate invalid element error")
    func mockSimulatesInvalidElement() async throws {
        var mock = MockAXBridge()
        mock.shouldThrowInvalidElement = true

        let element = try mock.createSystemWideElement()

        #expect(
            throws: AccessibilityError.self,
            performing: {
                let _: String = try mock.getAttribute(.title, from: element)
            }
        )
    }
}
