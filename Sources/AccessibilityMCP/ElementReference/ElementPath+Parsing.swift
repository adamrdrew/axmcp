import Foundation

extension ElementPath {
    static func parseApp(
        _ string: String
    ) throws(ElementPathError) -> ElementPathComponent {
        let content = extractContent(from: string, prefix: "app(", suffix: ")")
        guard let content else {
            throw ElementPathError.invalidFormat(string)
        }
        if content.hasPrefix("\"") && content.hasSuffix("\"") {
            let name = String(content.dropFirst().dropLast())
            return .appByName(name)
        } else if let pid = pid_t(content) {
            return .appByPID(pid)
        } else {
            throw ElementPathError.invalidFormat(string)
        }
    }

    static func parseWindow(
        _ string: String
    ) throws(ElementPathError) -> ElementPathComponent {
        let content = extractContent(from: string, prefix: "window[", suffix: "]")
        guard let content else {
            throw ElementPathError.invalidFormat(string)
        }
        if content.hasPrefix("\"") && content.hasSuffix("\"") {
            let title = String(content.dropFirst().dropLast())
            return .windowByTitle(title)
        } else if let index = Int(content) {
            return .windowByIndex(index)
        } else {
            throw ElementPathError.invalidFormat(string)
        }
    }

    static func parseChild(
        _ string: String
    ) throws(ElementPathError) -> ElementPathComponent {
        guard let bracketIndex = string.firstIndex(of: "[") else {
            throw ElementPathError.invalidFormat(string)
        }
        let roleString = String(string[..<bracketIndex])
        let role = ElementRole.from(string: roleString)
        let content = extractContent(
            from: string,
            prefix: roleString + "[",
            suffix: "]"
        )
        guard let content else {
            throw ElementPathError.invalidFormat(string)
        }
        if content.hasPrefix("\"") && content.hasSuffix("\"") {
            let title = String(content.dropFirst().dropLast())
            return .childByRoleAndTitle(role, title: title)
        } else if let index = Int(content) {
            return .childByRole(role, index: index)
        } else {
            throw ElementPathError.invalidFormat(string)
        }
    }

    static func extractContent(
        from string: String,
        prefix: String,
        suffix: String
    ) -> String? {
        guard string.hasPrefix(prefix) && string.hasSuffix(suffix) else {
            return nil
        }
        let start = string.index(string.startIndex, offsetBy: prefix.count)
        let end = string.index(string.endIndex, offsetBy: -suffix.count)
        return String(string[start..<end])
    }
}
