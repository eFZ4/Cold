import Foundation

/// Protocol for managing background runtime sessions on Apple Watch.
/// Real implementation uses WKExtendedRuntimeSession.
/// Mock implementation is used in tests.
protocol ExtendedRuntimeManaging: AnyObject, Sendable {
    func start()
    func stop()
}
