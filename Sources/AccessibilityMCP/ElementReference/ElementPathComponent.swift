import Foundation

enum ElementPathComponent: Equatable, Hashable, Sendable {
    case appByName(String)
    case appByPID(pid_t)
    case windowByIndex(Int)
    case windowByTitle(String)
    case childByRole(ElementRole, index: Int)
    case childByRoleAndTitle(ElementRole, title: String)

    func toString() -> String {
        switch self {
        case .appByName(let name):
            return "app(\"\(name)\")"
        case .appByPID(let pid):
            return "app(\(pid))"
        case .windowByIndex(let index):
            return "window[\(index)]"
        case .windowByTitle(let title):
            return "window[\"\(title)\"]"
        case .childByRole(let role, let index):
            return "\(role.rawValue)[\(index)]"
        case .childByRoleAndTitle(let role, let title):
            return "\(role.rawValue)[\"\(title)\"]"
        }
    }
}
