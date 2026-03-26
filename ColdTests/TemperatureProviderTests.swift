import XCTest
@testable import ColdWatch

final class TemperatureProviderTests: XCTestCase {

    // MARK: - MockTemperatureProvider

    func test_mock_initialTemperature_isInColdRange() async {
        let mock = MockTemperatureProvider()
        let temp = await mock.currentTemperature()
        XCTAssertGreaterThanOrEqual(temp, 0.0)
        XCTAssertLessThanOrEqual(temp, 20.0)
    }

    func test_mock_streamDeliversValues() async throws {
        let mock = MockTemperatureProvider()
        var received: [Double] = []

        let stream = mock.temperatureStream()
        for await value in stream.prefix(3) {
            received.append(value)
        }

        XCTAssertEqual(received.count, 3)
        for temp in received {
            XCTAssertGreaterThanOrEqual(temp, 0.0)
            XCTAssertLessThanOrEqual(temp, 20.0)
        }
    }

    func test_mock_customInitialTemperature() async {
        let mock = MockTemperatureProvider(initialTemperature: 5.0)
        let temp = await mock.currentTemperature()
        XCTAssertEqual(temp, 5.0, accuracy: 0.001)
    }

    func test_mock_temperatureChangesOverTime() async throws {
        let mock = MockTemperatureProvider(initialTemperature: 10.0)
        var values: [Double] = []

        let stream = mock.temperatureStream()
        for await v in stream.prefix(5) {
            values.append(v)
        }

        // Values should not all be identical (simulated noise)
        let unique = Set(values.map { ($0 * 10).rounded() })
        XCTAssertGreaterThan(unique.count, 1, "Mock should produce varying temperatures")
    }

    // MARK: - TemperatureProviderFactory

    func test_factory_returnsMockInSimulator() {
        let provider = TemperatureProviderFactory.makeProvider()
        // In the simulator environment, the factory must return a mock
        XCTAssertTrue(provider is MockTemperatureProvider,
                      "Expected MockTemperatureProvider in simulator, got \(type(of: provider))")
    }
}
