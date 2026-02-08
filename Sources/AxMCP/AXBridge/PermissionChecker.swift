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
            guidance: "Open System Settings > Privacy & Security > Accessibility and enable this application. You may need to restart after granting permission."
        )
    }
}
