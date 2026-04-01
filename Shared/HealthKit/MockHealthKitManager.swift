import Foundation

/// Test double for HealthKitManaging.
/// Records calls for assertion in unit tests.
final class MockHealthKitManager: HealthKitManaging, @unchecked Sendable {
    private(set) var authorizationRequested = false
    private(set) var savedSessions: [IceBathSession] = []
    var shouldThrowOnSave = false

    func requestAuthorization() async throws {
        authorizationRequested = true
    }

    func saveSession(_ session: IceBathSession) async throws {
        if shouldThrowOnSave {
            throw MockError.simulatedFailure
        }
        savedSessions.append(session)
    }

    enum MockError: Error {
        case simulatedFailure
    }
}
