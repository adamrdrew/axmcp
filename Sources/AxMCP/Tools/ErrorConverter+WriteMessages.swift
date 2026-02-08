import Foundation

extension ErrorConverter {
    static func elementPathMessage(
        _ error: ElementPathError
    ) -> String {
        switch error {
        case .invalidFormat(let fmt):
            return "Invalid element path format: \(fmt)"
        case .emptyPath:
            return "Element path is empty"
        case .pathTooLong(let len):
            return "Element path has \(len) components (too long)"
        case .invalidPID(let pid):
            return "Invalid PID: \(pid)"
        case .componentNotFound(let comp, let available):
            return "Path component \(comp) not found. Available: \(available.joined(separator: ", "))"
        case .elementNotFound(let path):
            return "Element not found at path: \(path)"
        case .staleReference(let path):
            return "Stale element reference: \(path)"
        case .timeoutExceeded(let t):
            return "Path resolution timed out after \(t)s"
        case .accessibilityError(let axErr):
            return "Accessibility error during path resolution: \(axErr)"
        }
    }

    static func elementPathGuidance(
        _ error: ElementPathError
    ) -> String {
        switch error {
        case .staleReference:
            return "The UI has changed since this path was obtained. Re-run get_ui_tree or find_element to get a fresh path."
        case .elementNotFound:
            return "The element may have been removed. Re-run get_ui_tree or find_element to get current paths."
        case .componentNotFound:
            return "A path segment does not match the current UI. Re-run get_ui_tree to see the current element hierarchy."
        case .timeoutExceeded:
            return "The application may be slow. Try again or target a simpler element path."
        default:
            return "Check the element path syntax. Paths are returned by get_ui_tree and find_element."
        }
    }

    static func blocklistGuidance(
        _ error: BlocklistError
    ) -> String {
        switch error {
        case .blockedApplication(_, let bundleID):
            return "Bundle ID '\(bundleID)' is on the write blocklist. Read operations are still allowed. To customize, set ACCESSIBILITY_MCP_BLOCKLIST with comma-separated bundle IDs."
        }
    }
}
