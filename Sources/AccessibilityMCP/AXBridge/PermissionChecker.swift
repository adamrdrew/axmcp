import ApplicationServices

struct PermissionChecker: Sendable {
    func checkAccessibilityPermissions(
    ) throws(AccessibilityError) {
        guard AXIsProcessTrusted() else {
            throw permissionDeniedError()
        }
    }

    private func permissionDeniedError(
    ) -> AccessibilityError {
        .permissionDenied(
            guidance: "Grant Accessibility permissions in System Settings > Privacy & Security > Accessibility"
        )
    }
}
