import Foundation

/// Simulates water temperature readings for use in the simulator.
/// Produces realistic cold-water values (0–20°C) with slight random noise.
actor MockTemperatureProvider: TemperatureProviding {

    private var currentTemp: Double
    private let updateInterval: TimeInterval

    init(initialTemperature: Double = 8.0, updateInterval: TimeInterval = 1.0) {
        self.currentTemp = initialTemperature
        self.updateInterval = updateInterval
    }

    func currentTemperature() async -> Double {
        currentTemp
    }

    nonisolated func temperatureStream() -> AsyncStream<Double> {
        AsyncStream { [weak self] continuation in
            guard let self else {
                continuation.finish()
                return
            }
            Task {
                while !Task.isCancelled {
                    let value = await self.nextSimulatedTemperature()
                    continuation.yield(value)
                    try? await Task.sleep(for: .seconds(self.updateInterval))
                }
                continuation.finish()
            }
        }
    }

    // MARK: - Private

    private func nextSimulatedTemperature() -> Double {
        let noise = Double.random(in: -0.3...0.3)
        currentTemp = max(0.0, min(20.0, currentTemp + noise))
        return currentTemp
    }
}
