import Foundation

protocol AppResolver: Sendable {
    func resolve(
        appIdentifier: String
    ) throws(AppResolutionError) -> pid_t
}
