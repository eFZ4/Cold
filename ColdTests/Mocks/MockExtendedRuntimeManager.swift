@testable import ColdWatch

final class MockExtendedRuntimeManager: ExtendedRuntimeManaging, @unchecked Sendable {
    private(set) var didStart = false
    private(set) var didStop = false

    func start() { didStart = true }
    func stop() { didStop = true }
}
