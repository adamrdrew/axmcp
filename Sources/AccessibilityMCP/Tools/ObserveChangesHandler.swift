import Foundation

struct ObserveChangesHandler: Sendable {
    private let resolver: any AppResolver
    private let bridge: any AXBridge
    let observerManager: ObserverManager
    private let elementResolver = ElementResolver()
    let eventCollector = EventCollector()

    init(
        resolver: any AppResolver,
        bridge: any AXBridge,
        observerManager: ObserverManager
    ) {
        self.resolver = resolver
        self.bridge = bridge
        self.observerManager = observerManager
    }

    func execute(
        parameters: ObserveChangesParameters
    ) async throws(ToolExecutionError) -> ObserveChangesResponse {
        do {
            try parameters.validate()
            let pid = try resolvePID(parameters.app)
            let element = try resolveElement(pid, parameters)
            let notifications = resolveNotifications(parameters)
            let duration = parameters.effectiveDuration
            return try await observe(
                pid: pid, element: element,
                notifications: notifications,
                parameters: parameters,
                duration: duration
            )
        } catch let error as ToolParameterError {
            throw convertParameterError(error, parameters)
        } catch let error as AppResolutionError {
            throw convertAppError(error, parameters)
        } catch let error as ElementPathError {
            throw convertPathError(error, parameters)
        } catch let error as ObserverError {
            throw convertObserverError(error, parameters)
        } catch let error as ToolExecutionError {
            throw error
        } catch {
            throw createUnknownError(error, parameters)
        }
    }

    private func resolvePID(
        _ app: String
    ) throws(AppResolutionError) -> pid_t {
        try resolver.resolve(appIdentifier: app)
    }

    private func resolveElement(
        _ pid: pid_t,
        _ params: ObserveChangesParameters
    ) throws(ElementPathError) -> UIElement? {
        guard let pathStr = params.elementPath else {
            return nil
        }
        let path = try ElementPath(parsing: pathStr)
        return try elementResolver.resolve(
            path: path, bridge: bridge
        )
    }

    private func resolveNotifications(
        _ params: ObserveChangesParameters
    ) -> [String] {
        guard let events = params.events else {
            return defaultNotifications()
        }
        return events.compactMap { name in
            ObserverEventType(rawValue: name)?
                .axNotificationName
        }
    }

    private func defaultNotifications() -> [String] {
        [
            ObserverEventType.valueChanged,
            .focusChanged, .windowCreated,
            .windowDestroyed, .titleChanged
        ].map(\.axNotificationName)
    }

    private func observe(
        pid: pid_t,
        element: UIElement?,
        notifications: [String],
        parameters: ObserveChangesParameters,
        duration: Int
    ) async throws(ObserverError) -> ObserveChangesResponse {
        let (stream, continuation, id) = try await startStream(
            pid: pid, element: element,
            notifications: notifications
        )
        let result = await eventCollector.collect(
            from: stream, duration: TimeInterval(duration)
        )
        continuation.finish()
        await observerManager.stopObservation(id: id)
        return buildResponse(result, parameters)
    }
}
