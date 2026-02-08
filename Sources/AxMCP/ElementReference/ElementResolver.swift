import Foundation

struct ElementResolver: Sendable {
    private let maxPathLength = 50
    private let defaultTimeout: TimeInterval = 5.0

    func resolve(
        path: ElementPath,
        bridge: any AXBridge,
        timeout: TimeInterval? = nil
    ) throws(ElementPathError) -> UIElement {
        try validatePath(path)
        let timeoutValue = timeout ?? defaultTimeout
        let deadline = Date().addingTimeInterval(timeoutValue)
        return try walkPath(
            path: path,
            bridge: bridge,
            deadline: deadline,
            timeout: timeoutValue
        )
    }

    private func validatePath(
        _ path: ElementPath
    ) throws(ElementPathError) {
        guard !path.components.isEmpty else {
            throw ElementPathError.emptyPath
        }
        guard path.components.count <= maxPathLength else {
            throw ElementPathError.pathTooLong(path.components.count)
        }
        try validatePID(in: path)
    }

    private func validatePID(
        in path: ElementPath
    ) throws(ElementPathError) {
        guard let first = path.components.first else { return }
        if case .appByPID(let pid) = first {
            guard pid > 0 else {
                throw ElementPathError.invalidPID(pid)
            }
        }
    }

    private func walkPath(
        path: ElementPath,
        bridge: any AXBridge,
        deadline: Date,
        timeout: TimeInterval
    ) throws(ElementPathError) -> UIElement {
        try checkTimeout(deadline: deadline, timeout: timeout)
        var current = try resolveFirst(path.components[0], bridge: bridge)
        for component in path.components.dropFirst() {
            try checkTimeout(deadline: deadline, timeout: timeout)
            current = try resolveNext(
                component: component,
                from: current,
                bridge: bridge
            )
        }
        return current
    }

    private func checkTimeout(
        deadline: Date,
        timeout: TimeInterval
    ) throws(ElementPathError) {
        guard Date() <= deadline else {
            throw ElementPathError.timeoutExceeded(timeout)
        }
    }
}
