import Testing
@testable import AccessibilityMCP

@Suite("App Resolver Tests")
struct AppResolverTests {
    @Test("Resolves numeric PID directly")
    func resolvesNumericPID() throws {
        let resolver = MockAppResolver()
        let pid = try resolver.resolve(appIdentifier: "12345")
        #expect(pid == 12345)
    }

    @Test("Resolves app name to PID")
    func resolvesAppName() throws {
        var resolver = MockAppResolver()
        resolver.mockApps = ["Finder": 100, "Safari": 200]
        let pid = try resolver.resolve(appIdentifier: "Finder")
        #expect(pid == 100)
    }

    @Test("Throws when app not running")
    func throwsWhenNotRunning() {
        var resolver = MockAppResolver()
        resolver.shouldThrowNotRunning = true
        #expect(
            throws: AppResolutionError.self,
            performing: {
                try resolver.resolve(appIdentifier: "NonExistent")
            }
        )
    }

    @Test("Throws when multiple matches found")
    func throwsWhenMultipleMatches() {
        var resolver = MockAppResolver()
        resolver.shouldThrowMultipleMatches = true
        #expect(
            throws: AppResolutionError.self,
            performing: {
                try resolver.resolve(appIdentifier: "Ambiguous")
            }
        )
    }

    @Test("Rejects invalid PID values")
    func rejectsInvalidPID() {
        let resolver = MockAppResolver()
        #expect(
            throws: AppResolutionError.self,
            performing: {
                try resolver.resolve(appIdentifier: "-1")
            }
        )
    }

    @Test("Rejects zero PID")
    func rejectsZeroPID() {
        let resolver = MockAppResolver()
        #expect(
            throws: AppResolutionError.self,
            performing: {
                try resolver.resolve(appIdentifier: "0")
            }
        )
    }
}
