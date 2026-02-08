import Testing
import Foundation
@testable import AxMCP

@Suite("ElementStateReader Tests")
struct ElementStateReaderTests {
    @Test("Reads full element state")
    func testFullState() throws {
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .role: "AXButton",
            .title: "OK",
            .value: "button-value",
            .enabled: true,
            .focused: false
        ]
        bridge.mockActions = [.press, .cancel]
        let reader = ElementStateReader()
        let element = bridge.createMockElement()
        let state = try reader.readState(
            element: element,
            path: "app/window[0]/button[0]",
            bridge: bridge
        )
        #expect(state.role == "AXButton")
        #expect(state.title == "OK")
        #expect(state.value == "button-value")
        #expect(state.enabled == true)
        #expect(state.focused == false)
        #expect(state.actions.count == 2)
        #expect(state.path == "app/window[0]/button[0]")
    }

    @Test("Handles missing attributes gracefully")
    func testPartialState() throws {
        var bridge = MockAXBridge()
        bridge.mockAttributes = [
            .role: "AXButton"
        ]
        let reader = ElementStateReader()
        let element = bridge.createMockElement()
        let state = try reader.readState(
            element: element,
            path: "app/button[0]",
            bridge: bridge
        )
        #expect(state.role == "AXButton")
        #expect(state.title == nil)
        #expect(state.value == nil)
        #expect(state.enabled == nil)
        #expect(state.focused == nil)
        #expect(state.actions.isEmpty)
    }

    @Test("Returns empty actions on error")
    func testActionsError() throws {
        var bridge = MockAXBridge()
        bridge.mockAttributes = [.role: "AXButton"]
        bridge.shouldThrowInvalidElement = true
        let reader = ElementStateReader()
        let element = bridge.createMockElement()
        bridge.shouldThrowInvalidElement = false
        let state = try reader.readState(
            element: element,
            path: "app/button[0]",
            bridge: bridge
        )
        #expect(state.actions.isEmpty)
    }
}
