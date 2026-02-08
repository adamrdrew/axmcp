import Foundation

extension TreeTraverser {
    func buildChildPath(
        parentPath: String,
        role: String,
        index: Int
    ) -> String {
        if role == "AXWindow" {
            return "\(parentPath)/window[\(index)]"
        } else {
            return "\(parentPath)/\(role)[\(index)]"
        }
    }

    func buildPath(
        components: [String],
        role: String,
        applicationPID: pid_t
    ) -> String {
        if components.isEmpty {
            return "app(\(applicationPID))"
        }
        let allComponents = components + [role]
        return allComponents.joined(separator: "/")
    }
}
