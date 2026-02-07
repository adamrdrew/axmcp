import Foundation
import AppKit

struct ListWindowsHandler: Sendable {
    private let resolver: any AppResolver
    private let bridge: any AXBridge
    private let converter: WindowInfoConverter

    init(resolver: any AppResolver, bridge: any AXBridge) {
        self.resolver = resolver
        self.bridge = bridge
        self.converter = WindowInfoConverter(bridge: bridge)
    }

    func execute(
        parameters: ListWindowsParameters
    ) throws(ToolExecutionError) -> ListWindowsResponse {
        do {
            try parameters.validate()
            let windows = try getWindows(parameters)
            let filtered = filterWindows(windows, parameters)
            return createResponse(filtered)
        } catch let error as AppResolutionError {
            throw ErrorConverter.convertAppError(error, operation: "list_windows")
        } catch let error as AccessibilityError {
            throw ErrorConverter.convertAccessibilityError(error, operation: "list_windows", app: parameters.app)
        } catch {
            throw ToolExecutionError.toolError(
                ToolError(
                    operation: "list_windows",
                    errorType: "unknown_error",
                    message: "Unexpected error: \(error)",
                    app: parameters.app
                )
            )
        }
    }

    private func getWindows(
        _ params: ListWindowsParameters
    ) throws -> [WindowInfo] {
        if let appName = params.app {
            return try getAppWindows(appName)
        }
        return try getSystemWindows()
    }

    private func getAppWindows(_ appName: String) throws -> [WindowInfo] {
        let pid = try resolver.resolve(appIdentifier: appName)
        let appElement = try bridge.createApplicationElement(pid: pid)
        let windows: [UIElement] = (
            try? bridge.getAttribute(.windows, from: appElement)
        ) ?? []
        return windows.compactMap { converter.convert($0, appName: appName) }
    }

    private func getSystemWindows() throws -> [WindowInfo] {
        let workspace = NSWorkspace.shared
        var allWindows: [WindowInfo] = []
        for app in workspace.runningApplications {
            if let appName = app.localizedName {
                let windows = try? getAppWindows(appName)
                allWindows.append(contentsOf: windows ?? [])
            }
        }
        return allWindows
    }

    private func filterWindows(
        _ windows: [WindowInfo],
        _ params: ListWindowsParameters
    ) -> [WindowInfo] {
        if params.effectiveIncludeMinimized() {
            return windows
        }
        return windows.filter { !$0.minimized }
    }

    private func createResponse(
        _ windows: [WindowInfo]
    ) -> ListWindowsResponse {
        ListWindowsResponse(windows: windows)
    }
}
