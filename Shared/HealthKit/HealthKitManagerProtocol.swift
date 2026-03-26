import Foundation

/// Protocol for saving cold water immersion sessions to Apple Health.
/// Concrete implementation: HealthKitManager (requires entitlements + user authorization).
/// Test double: MockHealthKitManager.
protocol HealthKitManaging: AnyObject, Sendable {
    /// Requests HealthKit read/write authorization for required types.
    /// Must be called before saveSession(_:).
    func requestAuthorization() async throws

    /// Saves an IceBathSession as an HKWorkout (waterSports) with
    /// associated water temperature samples.
    /// Privacy: only stores session metrics — no HealthKit record identifiers
    /// are written to the shared App Group container.
    func saveSession(_ session: IceBathSession) async throws
}
