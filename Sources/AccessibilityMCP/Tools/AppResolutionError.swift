import Foundation

enum AppResolutionError: Error, Sendable {
    case notRunning(appName: String)
    case multipleMatches(appName: String, matches: [String])
    case invalidIdentifier(identifier: String)
}
