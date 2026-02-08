import Foundation

actor ServerContext {
    let configuration: ServerConfiguration
    let blocklist: ApplicationBlocklist
    let rateLimiter: RateLimiter
    let observerManager: ObserverManager

    init(configuration: ServerConfiguration) {
        self.configuration = configuration
        self.blocklist = ApplicationBlocklist(
            additionalBlockedIDs: configuration.blockedBundleIDs
        )
        self.rateLimiter = RateLimiter(
            maxActionsPerSecond: configuration.rateLimitPerSecond
        )
        self.observerManager = ObserverManager(
            bridge: LiveObserverBridge()
        )
    }

    func getConfiguration() -> ServerConfiguration {
        configuration
    }

    func getBlocklist() -> ApplicationBlocklist {
        blocklist
    }

    func getRateLimiter() -> RateLimiter {
        rateLimiter
    }

    func getObserverManager() -> ObserverManager {
        observerManager
    }
}
