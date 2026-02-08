import Foundation

enum BlocklistError: Error, Sendable {
    case blockedApplication(appName: String, bundleID: String)
}
