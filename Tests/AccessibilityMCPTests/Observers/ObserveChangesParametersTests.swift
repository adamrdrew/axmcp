import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("ObserveChangesParameters Tests")
struct ObserveChangesParametersTests {

    @Test("Valid parameters pass validation")
    func validParametersPass() throws {
        let params = ObserveChangesParameters(
            app: "Safari",
            events: ["value_changed"],
            elementPath: nil,
            duration: 10
        )
        try params.validate()
    }

    @Test("Empty app throws missing required")
    func emptyAppThrows() {
        let params = ObserveChangesParameters(
            app: "",
            events: nil,
            elementPath: nil,
            duration: nil
        )
        #expect(throws: ToolParameterError.self) {
            try params.validate()
        }
    }

    @Test("Invalid event type throws error")
    func invalidEventTypeThrows() {
        let params = ObserveChangesParameters(
            app: "Safari",
            events: ["invalid_event"],
            elementPath: nil,
            duration: nil
        )
        #expect(throws: ToolParameterError.self) {
            try params.validate()
        }
    }

    @Test("Default duration is 30 seconds")
    func defaultDuration() {
        let params = ObserveChangesParameters(
            app: "Safari",
            events: nil,
            elementPath: nil,
            duration: nil
        )
        #expect(params.effectiveDuration == 30)
    }

    @Test("Duration clamped to max 300")
    func durationClampedToMax() {
        let params = ObserveChangesParameters(
            app: "Safari",
            events: nil,
            elementPath: nil,
            duration: 500
        )
        #expect(params.effectiveDuration == 300)
        #expect(params.durationWasClamped == true)
    }

    @Test("Duration clamped to min 1")
    func durationClampedToMin() {
        let params = ObserveChangesParameters(
            app: "Safari",
            events: nil,
            elementPath: nil,
            duration: 0
        )
        #expect(params.effectiveDuration == 1)
        #expect(params.durationWasClamped == true)
    }

    @Test("Valid duration not clamped")
    func validDurationNotClamped() {
        let params = ObserveChangesParameters(
            app: "Safari",
            events: nil,
            elementPath: nil,
            duration: 60
        )
        #expect(params.effectiveDuration == 60)
        #expect(params.durationWasClamped == false)
    }

    @Test("Decodes from JSON")
    func decodesFromJSON() throws {
        let json = """
        {"app":"Finder","events":["focus_changed"],"duration":15}
        """
        let data = json.data(using: .utf8)!
        let params = try JSONDecoder().decode(
            ObserveChangesParameters.self,
            from: data
        )
        #expect(params.app == "Finder")
        #expect(params.events == ["focus_changed"])
        #expect(params.duration == 15)
        #expect(params.elementPath == nil)
    }
}
