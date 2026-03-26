import Foundation
import WatchKit

/// Manages a WKExtendedRuntimeSession to keep the timer running while the watch screen is off.
/// Requires WKBackgroundModes: [workout-processing] in Info.plist.
final class ExtendedRuntimeManager: NSObject, ExtendedRuntimeManaging,
    WKExtendedRuntimeSessionDelegate, @unchecked Sendable {

    private var session: WKExtendedRuntimeSession?

    func start() {
        guard session == nil else { return }
        let s = WKExtendedRuntimeSession()
        s.delegate = self
        s.start()
        session = s
    }

    func stop() {
        session?.invalidate()
        session = nil
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
