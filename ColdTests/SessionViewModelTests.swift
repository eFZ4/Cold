import XCTest
@testable import ColdWatch

@MainActor
final class SessionViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeSUT(
        temperature: Double = 8.0,
        tickInterval: Duration = .milliseconds(50)
    ) -> SessionViewModel {
        let mock = MockTemperatureProvider(initialTemperature: temperature,
                                          updateInterval: 0.05)
        let runtime = MockExtendedRuntimeManager()
        return SessionViewModel(
            temperatureProvider: mock,
            runtimeManager: runtime,
            tickInterval: tickInterval
        )
    }

    // MARK: - Initial state

    func test_initialState_isIdle() {
        let sut = makeSUT()
        if case .idle = sut.state { } else {
            XCTFail("Expected .idle, got \(sut.state)")
        }
    }

    // MARK: - Start → Active transition

    func test_start_transitionsToActive() async throws {
        let sut = makeSUT()
        sut.start()
        try await Task.sleep(for: .milliseconds(150))
        if case .active = sut.state { } else {
            XCTFail("Expected .active, got \(sut.state)")
        }
    }

    // MARK: - Elapsed time ticks

    func test_elapsedTime_incrementsWhileActive() async throws {
        let sut = makeSUT(tickInterval: .milliseconds(50))
        sut.start()
        try await Task.sleep(for: .milliseconds(300))

        guard case let .active(elapsed, _) = sut.state else {
            XCTFail("Expected .active state"); return
        }
        XCTAssertGreaterThan(elapsed, 0.1, "Elapsed should have grown beyond one tick")
    }

    // MARK: - Stop → Summary transition

    func test_stop_transitionsToSummary() async throws {
        let sut = makeSUT()
        sut.start()
        try await Task.sleep(for: .milliseconds(150))
        sut.stop()
        try await Task.sleep(for: .milliseconds(100))

        if case .summary = sut.state { } else {
            XCTFail("Expected .summary, got \(sut.state)")
        }
    }

    // MARK: - Summary contains session data

    func test_stop_summaryContainsDuration() async throws {
        let sut = makeSUT(tickInterval: .milliseconds(50))
        sut.start()
        try await Task.sleep(for: .milliseconds(300))
        sut.stop()
        try await Task.sleep(for: .milliseconds(50))

        guard case let .summary(session) = sut.state else {
            XCTFail("Expected .summary state"); return
        }
        XCTAssertGreaterThan(session.duration, 0.1)
    }

    func test_stop_summaryContainsTemperatureReadings() async throws {
        let sut = makeSUT()
        sut.start()
        try await Task.sleep(for: .milliseconds(300))
        sut.stop()
        try await Task.sleep(for: .milliseconds(50))

        guard case let .summary(session) = sut.state else {
            XCTFail("Expected .summary state"); return
        }
        XCTAssertFalse(session.temperatureReadings.isEmpty,
                       "Summary should have temperature readings")
    }

    // MARK: - Reset from summary

    func test_reset_fromSummary_returnsToIdle() async throws {
        let sut = makeSUT()
        sut.start()
        try await Task.sleep(for: .milliseconds(150))
        sut.stop()
        try await Task.sleep(for: .milliseconds(50))
        sut.reset()

        if case .idle = sut.state { } else {
            XCTFail("Expected .idle after reset, got \(sut.state)")
        }
    }

    // MARK: - Stop while idle is a no-op

    func test_stop_whileIdle_remainsIdle() {
        let sut = makeSUT()
        sut.stop()
        if case .idle = sut.state { } else {
            XCTFail("Stop while idle should not change state")
        }
    }

    // MARK: - Extended runtime is started/stopped

    func test_start_activatesExtendedRuntime() async throws {
        let mock = MockTemperatureProvider()
        let runtime = MockExtendedRuntimeManager()
        let sut = SessionViewModel(temperatureProvider: mock, runtimeManager: runtime)
        sut.start()
        try await Task.sleep(for: .milliseconds(100))
        XCTAssertTrue(runtime.didStart, "Extended runtime should have been started")
    }

    func test_stop_invalidatesExtendedRuntime() async throws {
        let mock = MockTemperatureProvider()
        let runtime = MockExtendedRuntimeManager()
        let sut = SessionViewModel(temperatureProvider: mock, runtimeManager: runtime)
        sut.start()
        try await Task.sleep(for: .milliseconds(100))
        sut.stop()
        try await Task.sleep(for: .milliseconds(50))
        XCTAssertTrue(runtime.didStop, "Extended runtime should have been stopped")
    }
}
