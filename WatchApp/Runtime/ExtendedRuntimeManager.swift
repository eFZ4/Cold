import Foundation
import WatchKit

/// Manages a WKExtendedRuntimeSession to keep the timer running while the watch screen is off.
/// Requires WKBackgroundModes: [workout-processing] in Info.plist.
final class ExtendedRuntimeManager: NSObject, ExtendedRuntimeManaging,
    WKExtendedRuntimeSessionDelegate, @unchecked Sendable {

    private var session: WKExtendedRuntimeSession?

    func start() {
        #if targetEnvironment(simulator)
        return  // WKExtendedRuntimeSession is not supported in the simulator
        #else
        guard session == nil else { return }
        let s = WKExtendedRuntimeSession()
        s.delegate = self
        s.start()
        session = s
        #endif
    }

    func stop() {
        #if !targetEnvironment(simulator)
        session?.invalidate()
        session = nil
        #endif
    }

    // MARK: - WKExtendedRuntimeSessionDelegate

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {}

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // Session is about to expire — notify the UI to wrap up if still active
    }

    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession,
                                didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
                                error: (any Error)?) {}
}
