import Foundation
import ApplicationServices

final class RunLoopThread: Thread, @unchecked Sendable {
    private var observerRef: AXObserver?
    private var runLoopRef: CFRunLoop?
    private let lock = NSLock()

    func start(observer: AXObserver) {
        lock.lock()
        observerRef = observer
        lock.unlock()
        qualityOfService = .utility
        start()
    }

    override func main() {
        lock.lock()
        let observer = observerRef
        lock.unlock()
        guard let observer else { return }
        let source = AXObserverGetRunLoopSource(observer)
        let rl = CFRunLoopGetCurrent()
        lock.lock()
        runLoopRef = rl
        lock.unlock()
        CFRunLoopAddSource(rl, source, .defaultMode)
        CFRunLoopRun()
    }

    func stopRunLoop(observer: AXObserver) {
        lock.lock()
        let rl = runLoopRef
        lock.unlock()
        guard let rl else { return }
        let source = AXObserverGetRunLoopSource(observer)
        CFRunLoopRemoveSource(rl, source, .defaultMode)
        CFRunLoopStop(rl)
    }
}
