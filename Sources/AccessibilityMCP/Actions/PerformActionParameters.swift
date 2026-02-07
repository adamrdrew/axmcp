import Foundation

struct PerformActionParameters: Codable, Sendable {
    let app: String
    let elementPath: String
    let action: String

    init(app: String, elementPath: String, action: String) {
        self.app = app
        self.elementPath = elementPath
        self.action = action
    }

    func validate() throws(ToolParameterError) {
        guard !app.isEmpty else {
            throw ToolParameterError.missingRequired(
                parameter: "app"
            )
        }
        guard !elementPath.isEmpty else {
            throw ToolParameterError.missingRequired(
                parameter: "elementPath"
            )
        }
        guard !action.isEmpty else {
            throw ToolParameterError.missingRequired(
                parameter: "action"
            )
        }
        try validateAction()
    }

    private func validateAction() throws(ToolParameterError) {
        let validActions = [
            "AXPress", "AXPick", "AXShowMenu",
            "AXConfirm", "AXCancel", "AXRaise",
            "AXIncrement", "AXDecrement"
        ]
        guard validActions.contains(action) else {
            throw ToolParameterError.invalidValue(
                parameter: "action",
                value: action,
                reason: "Must be one of: \(validActions.joined(separator: ", "))"
            )
        }
    }
}
