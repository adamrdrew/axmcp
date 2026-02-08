import Foundation
@testable import AxMCP

struct MockAppResolver: AppResolver {
    var mockApps: [String: pid_t] = [:]
    var shouldThrowNotRunning = false
    var shouldThrowMultipleMatches = false

    func resolve(
        appIdentifier: String
    ) throws(AppResolutionError) -> pid_t {
        if shouldThrowNotRunning {
            throw AppResolutionError.notRunning(appName: appIdentifier)
        }
        if shouldThrowMultipleMatches {
            throw AppResolutionError.multipleMatches(
                appName: appIdentifier,
                matches: ["App1", "App2"]
            )
        }
        if let pid = pid_t(appIdentifier), pid > 0 {
            return pid
        }
        guard let pid = mockApps[appIdentifier] else {
            throw AppResolutionError.notRunning(appName: appIdentifier)
        }
        return pid
    }
}
