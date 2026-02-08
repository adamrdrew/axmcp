import Foundation
import AppKit

struct LiveAppResolver: AppResolver {
    func resolve(
        appIdentifier: String
    ) throws(AppResolutionError) -> pid_t {
        if let pid = tryParsePID(appIdentifier) {
            return pid
        }
        return try resolveByName(appIdentifier)
    }

    private func tryParsePID(_ identifier: String) -> pid_t? {
        guard let pid = pid_t(identifier), pid > 0 else {
            return nil
        }
        return pid
    }

    private func resolveByName(
        _ name: String
    ) throws(AppResolutionError) -> pid_t {
        let running = NSWorkspace.shared.runningApplications
        let matches = findMatches(name: name, in: running)
        return try selectMatch(name: name, from: matches)
    }

    private func findMatches(
        name: String,
        in apps: [NSRunningApplication]
    ) -> [NSRunningApplication] {
        apps.filter { app in
            matchesName(app, name: name)
        }
    }

    private func matchesName(
        _ app: NSRunningApplication,
        name: String
    ) -> Bool {
        let localizedName = app.localizedName ?? ""
        let bundleID = app.bundleIdentifier ?? ""
        return localizedName == name || bundleID == name
    }

    private func selectMatch(
        name: String,
        from matches: [NSRunningApplication]
    ) throws(AppResolutionError) -> pid_t {
        guard !matches.isEmpty else {
            throw AppResolutionError.notRunning(appName: name)
        }
        guard matches.count == 1 else {
            let matchNames = matches.compactMap { $0.localizedName }
            throw AppResolutionError.multipleMatches(
                appName: name,
                matches: matchNames
            )
        }
        return matches[0].processIdentifier
    }
}
