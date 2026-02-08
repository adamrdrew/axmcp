import Foundation

actor ApplicationBlocklist {
    private let blockedBundleIDs: Set<String>
    private static let defaultBlockedIDs: Set<String> = [
        "com.apple.keychainaccess",
        "com.apple.Terminal",
        "com.googlecode.iterm2",
        "com.apple.systempreferences"
    ]

    init(additionalBlockedIDs: [String] = []) {
        self.blockedBundleIDs = Self.defaultBlockedIDs
            .union(Set(additionalBlockedIDs))
    }

    func isBlocked(bundleID: String) -> Bool {
        blockedBundleIDs.contains(bundleID)
    }

    func isBlocked(
        appName: String,
        resolver: any AppResolver,
        bridge: any AXBridge
    ) async -> Bool {
        guard let bundleID = await resolveBundleID(
            appName: appName,
            resolver: resolver,
            bridge: bridge
        ) else {
            return false
        }
        return blockedBundleIDs.contains(bundleID)
    }

    private func resolveBundleID(
        appName: String,
        resolver: any AppResolver,
        bridge: any AXBridge
    ) async -> String? {
        guard let pid = try? resolver.resolve(
            appIdentifier: appName
        ) else {
            return nil
        }
        guard let element = try? bridge.createApplicationElement(
            pid: pid
        ) else {
            return nil
        }
        guard let bundleID: String = try? bridge.getAttribute(
            .custom("AXBundleIdentifier"),
            from: element
        ) else {
            return nil
        }
        return bundleID
    }
}
