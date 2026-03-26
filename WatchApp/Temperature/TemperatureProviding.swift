import Foundation

/// Protocol for providing water temperature readings.
/// Concrete implementations: MockTemperatureProvider (simulator), CMWaterSubmersionProvider (device).
protocol TemperatureProviding: AnyObject, Sendable {
    /// Returns the most recent temperature reading in Celsius.
    func currentTemperature() async -> Double

    /// Returns an AsyncStream of temperature values in Celsius.
    /// Values are delivered at implementation-defined intervals.
    func temperatureStream() -> AsyncStream<Double>
}
