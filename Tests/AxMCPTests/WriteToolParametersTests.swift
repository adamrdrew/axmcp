import Testing
import Foundation
@testable import AxMCP

@Suite("Write Tool Parameters Tests")
struct WriteToolParametersTests {
    @Test("PerformActionParameters decodes from JSON")
    func testPerformActionDecode() throws {
        let json = """
        {
            "app": "Safari",
            "elementPath": "app/window[0]/button[@title='Close']",
            "action": "AXPress"
        }
        """
        let data = json.data(using: .utf8)!
        let params = try JSONDecoder().decode(
            PerformActionParameters.self,
            from: data
        )
        #expect(params.app == "Safari")
        #expect(params.elementPath == "app/window[0]/button[@title='Close']")
        #expect(params.action == "AXPress")
    }

    @Test("PerformActionParameters validates required fields")
    func testPerformActionValidation() throws {
        let params = PerformActionParameters(
            app: "Safari",
            elementPath: "app/window[0]",
            action: "AXPress"
        )
        try params.validate()
    }

    @Test("PerformActionParameters rejects invalid action")
    func testPerformActionInvalidAction() {
        let params = PerformActionParameters(
            app: "Safari",
            elementPath: "app/window[0]",
            action: "InvalidAction"
        )
        do {
            try params.validate()
            Issue.record("Expected validation error")
        } catch {
            #expect(error is ToolParameterError)
        }
    }

    @Test("SetValueParameters decodes string value")
    func testSetValueString() throws {
        let json = """
        {
            "app": "TextEdit",
            "elementPath": "app/window[0]/textfield[0]",
            "value": "Hello World"
        }
        """
        let data = json.data(using: .utf8)!
        let params = try JSONDecoder().decode(
            SetValueParameters.self,
            from: data
        )
        if case .string(let value) = params.value {
            #expect(value == "Hello World")
        } else {
            Issue.record("Expected string value")
        }
    }

    @Test("SetValueParameters decodes boolean value")
    func testSetValueBoolean() throws {
        let json = """
        {
            "app": "Safari",
            "elementPath": "app/window[0]/checkbox[0]",
            "value": true
        }
        """
        let data = json.data(using: .utf8)!
        let params = try JSONDecoder().decode(
            SetValueParameters.self,
            from: data
        )
        if case .bool(let value) = params.value {
            #expect(value == true)
        } else {
            Issue.record("Expected boolean value")
        }
    }

    @Test("SetValueParameters decodes number value")
    func testSetValueNumber() throws {
        let json = """
        {
            "app": "iTunes",
            "elementPath": "app/window[0]/slider[0]",
            "value": 75
        }
        """
        let data = json.data(using: .utf8)!
        let params = try JSONDecoder().decode(
            SetValueParameters.self,
            from: data
        )
        if case .int(let value) = params.value {
            #expect(value == 75)
        } else {
            Issue.record("Expected integer value")
        }
    }

    @Test("Response structs encode to JSON")
    func testResponseSerialization() throws {
        let state = ElementStateInfo(
            role: "AXButton",
            title: "OK",
            value: nil,
            enabled: true,
            focused: false,
            actions: ["AXPress"],
            path: "app/window[0]/button[0]"
        )
        let response = ActionResponse(
            success: true,
            action: "AXPress",
            elementState: state,
            rateLimitWarning: nil
        )
        let data = try JSONEncoder().encode(response)
        let decoded = try JSONDecoder().decode(
            ActionResponse.self,
            from: data
        )
        #expect(decoded.success == true)
        #expect(decoded.action == "AXPress")
    }
}
