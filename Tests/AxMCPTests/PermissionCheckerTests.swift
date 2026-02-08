import Testing
@testable import AxMCP

@Suite("Permission Detection Tests")
struct PermissionCheckerTests {
    @Test("Permission error has actionable guidance")
    func permissionErrorGuidance() {
        let error = AccessibilityError.permissionDenied(
            guidance: "Grant Accessibility permissions in System Settings > Privacy & Security > Accessibility"
        )

        switch error {
        case .permissionDenied(let guidance):
            #expect(guidance.contains("System Settings"))
            #expect(guidance.contains("Accessibility"))
        default:
            Issue.record("Expected permissionDenied error")
        }
    }
}
