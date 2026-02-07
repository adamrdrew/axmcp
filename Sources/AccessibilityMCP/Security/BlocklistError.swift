import Foundation

enum BlocklistError: Error, Sendable {
    case blockedApplication(appName: String, bundleID: String)

    var guidance: String {
        switch self {
        case .blockedApplication:
            return "This application is blocklisted for write operations. Read operations are still permitted."
        }
    }
}
