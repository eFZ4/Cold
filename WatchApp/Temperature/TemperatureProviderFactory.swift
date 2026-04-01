import Foundation

/// Factory that selects the correct TemperatureProviding implementation.
/// This is the ONLY file that contains #if targetEnvironment(simulator).
/// All other files inject TemperatureProviding via protocol, with no awareness of the concrete type.
enum TemperatureProviderFactory {
    static func makeProvider() -> any TemperatureProviding {
        #if targetEnvironment(simulator)
        return MockTemperatureProvider()
        #else
        if #available(watchOS 9.0, *), CMWaterSubmersionManager.authorizationStatus() != .notDetermined {
            return CMWaterSubmersionProvider()
        } else {
            // Fallback for unsupported hardware (e.g., older Watch models)
            return MockTemperatureProvider()
        }
        #endif
    }
}
