import Foundation

struct WindowInfo: Codable, Sendable {
    let title: String?
    let position: Position
    let size: Size
    let minimized: Bool
    let frontmost: Bool
    let app: String

    struct Position: Codable, Sendable {
        let x: Double
        let y: Double

        init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }
    }

    struct Size: Codable, Sendable {
        let width: Double
        let height: Double

        init(width: Double, height: Double) {
            self.width = width
            self.height = height
        }
    }

    init(
        title: String?,
        position: Position,
        size: Size,
        minimized: Bool,
        frontmost: Bool,
        app: String
    ) {
        self.title = title
        self.position = position
        self.size = size
        self.minimized = minimized
        self.frontmost = frontmost
        self.app = app
    }
}
