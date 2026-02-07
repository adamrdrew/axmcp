import Foundation

struct SetValueHandler: Sendable {
    private let resolver: any AppResolver
    private let bridge: any AXBridge
    private let elementResolver = ElementResolver()
    private let stateReader = ElementStateReader()
    private let blocklist: ApplicationBlocklist
    private let rateLimiter: RateLimiter
    private let config: ServerConfiguration

    init(
        resolver: any AppResolver,
        bridge: any AXBridge,
        blocklist: ApplicationBlocklist,
        rateLimiter: RateLimiter,
        config: ServerConfiguration
    ) {
        self.resolver = resolver
        self.bridge = bridge
        self.blocklist = blocklist
        self.rateLimiter = rateLimiter
        self.config = config
    }

    func execute(
        parameters: SetValueParameters
    ) async throws(ToolExecutionError) -> SetValueResponse {
        do {
            try parameters.validate()
            try checkReadOnlyMode()
            let pid = try resolvePID(parameters.app)
            try await checkBlocklist(parameters.app)
            let rateLimitResult = await checkRateLimit()
            let element = try resolveElement(pid, parameters)
            let previousValue = readCurrentValue(element)
            try setValue(element, parameters)
            let state = try readState(element, parameters)
            return createResponse(
                previousValue: previousValue,
                state: state,
                rateLimitResult: rateLimitResult
            )
        } catch let error as ToolParameterError {
            throw convertParameterError(error, parameters)
        } catch let error as AppResolutionError {
            throw convertAppError(error, parameters)
        } catch let error as BlocklistError {
            throw convertBlocklistError(error, parameters)
        } catch let error as ElementPathError {
            throw convertPathError(error, parameters)
        } catch let error as AccessibilityError {
            throw convertAccessibilityError(error, parameters)
        } catch let error as ToolExecutionError {
            throw error
        } catch {
            throw createUnknownError(error, parameters)
        }
    }

    private func checkReadOnlyMode() throws(ToolExecutionError) {
        guard !config.readOnlyMode else {
            throw ToolExecutionError.toolError(
                ToolError(
                    operation: "set_value",
                    errorType: "read_only_mode",
                    message: "Write operations are disabled in read-only mode",
                    guidance: "Remove --read-only flag or ACCESSIBILITY_MCP_READ_ONLY env var"
                )
            )
        }
    }

    private func resolvePID(
        _ app: String
    ) throws(AppResolutionError) -> pid_t {
        try resolver.resolve(appIdentifier: app)
    }

    private func checkBlocklist(
        _ app: String
    ) async throws(BlocklistError) {
        let blocked = await blocklist.isBlocked(
            appName: app,
            resolver: resolver,
            bridge: bridge
        )
        guard !blocked else {
            throw BlocklistError.blockedApplication(
                appName: app,
                bundleID: "unknown"
            )
        }
    }

    private func checkRateLimit() async -> RateLimitResult {
        await rateLimiter.checkAndRecord()
    }

    private func resolveElement(
        _ pid: pid_t,
        _ parameters: SetValueParameters
    ) throws(ElementPathError) -> UIElement {
        let path = try ElementPath(parsing: parameters.elementPath)
        return try elementResolver.resolve(path: path, bridge: bridge)
    }

    private func readCurrentValue(_ element: UIElement) -> String? {
        try? bridge.getAttribute(.value, from: element)
    }

    private func setValue(
        _ element: UIElement,
        _ parameters: SetValueParameters
    ) throws(AccessibilityError) {
        let coercedValue = coerceValue(parameters.value)
        try bridge.setAttribute(.value, value: coercedValue, on: element)
    }

    private func coerceValue(_ value: AnyCodableValue) -> Any {
        switch value {
        case .string(let v): return v
        case .bool(let v): return v
        case .int(let v): return v
        case .double(let v): return v
        }
    }

    private func readState(
        _ element: UIElement,
        _ parameters: SetValueParameters
    ) throws(AccessibilityError) -> ElementStateInfo {
        try stateReader.readState(
            element: element,
            path: parameters.elementPath,
            bridge: bridge
        )
    }

    private func createResponse(
        previousValue: String?,
        state: ElementStateInfo,
        rateLimitResult: RateLimitResult
    ) -> SetValueResponse {
        SetValueResponse(
            success: true,
            previousValue: previousValue,
            newValue: state.value,
            elementState: state,
            rateLimitWarning: rateLimitResult.warningMessage
        )
    }
}
