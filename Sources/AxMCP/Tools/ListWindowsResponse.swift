import Foundation

struct ListWindowsResponse: Codable, Sendable {
    let windows: [WindowInfo]

    init(windows: [WindowInfo]) {
        self.windows = windows
    }
}
