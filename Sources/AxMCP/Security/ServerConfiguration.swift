import Foundation

struct ServerConfiguration: Sendable {
    let readOnlyMode: Bool
    let rateLimitPerSecond: Int
    let blockedBundleIDs: [String]

    init(
        readOnlyMode: Bool = false,
        rateLimitPerSecond: Int = 10,
        blockedBundleIDs: [String] = []
    ) {
        self.readOnlyMode = readOnlyMode
        self.rateLimitPerSecond = rateLimitPerSecond
        self.blockedBundleIDs = blockedBundleIDs
    }

    static func fromEnvironment() -> ServerConfiguration {
        let readOnlyFromEnv = parseReadOnlyEnv()
        let readOnlyFromCLI = parseReadOnlyCLI()
        let rateLimitEnv = parseRateLimitEnv()
        let blocklistEnv = parseBlocklistEnv()
        return ServerConfiguration(
            readOnlyMode: readOnlyFromCLI || readOnlyFromEnv,
            rateLimitPerSecond: rateLimitEnv,
            blockedBundleIDs: blocklistEnv
        )
    }

    private static func parseReadOnlyEnv() -> Bool {
        guard let value = getEnvValue("ACCESSIBILITY_MCP_READ_ONLY") else {
            return false
        }
        return value == "1" || value.lowercased() == "true"
    }

    private static func parseReadOnlyCLI() -> Bool {
        CommandLine.arguments.contains("--read-only")
    }

    private static func parseRateLimitEnv() -> Int {
        guard let value = getEnvValue("ACCESSIBILITY_MCP_RATE_LIMIT"),
              let limit = Int(value), limit > 0 else {
            return 10
        }
        return limit
    }

    private static func parseBlocklistEnv() -> [String] {
        guard let value = getEnvValue("ACCESSIBILITY_MCP_BLOCKLIST") else {
            return []
        }
        return value.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private static func getEnvValue(_ key: String) -> String? {
        ProcessInfo.processInfo.environment[key]
    }
}
