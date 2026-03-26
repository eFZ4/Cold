import Foundation
import CoreMotion

/// Provides real water temperature readings from CMWaterSubmersionManager.
/// Only delivers readings on Apple Watch Ultra and Series 10+ hardware.
/// On unsupported devices/simulator this class is never instantiated —
/// TemperatureProviderFactory selects MockTemperatureProvider instead.
@available(watchOS 9.0, *)
final class CMWaterSubmersionProvider: NSObject, TemperatureProviding,
    CMWaterSubmersionManagerDelegate, @unchecked Sendable {

    private let manager = CMWaterSubmersionManager()
    // Written only from the serial delegateQueue; read only on the same queue or via async hop.
    nonisolated(unsafe) private var latestTemp: Double = 0.0
    nonisolated(unsafe) private var continuations: [AsyncStream<Double>.Continuation] = []
    private let delegateQueue = DispatchQueue(label: "CMWaterSubmersionProvider.delegate",
                                              qos: .userInitiated)

    override init() {
        super.init()
        manager.delegate = self
    }

    func currentTemperature() async -> Double {
        await withCheckedContinuation { continuation in
            delegateQueue.async { [self] in
                continuation.resume(returning: self.latestTemp)
            }
        }
    }

    nonisolated func temperatureStream() -> AsyncStream<Double> {
        AsyncStream { [weak self] continuation in
            guard let self else { continuation.finish(); return }
            self.delegateQueue.async {
                self.continuations.append(continuation)
            }
            continuation.onTermination = { [weak self] _ in
                guard let self else { return }
                self.delegateQueue.async {
                    self.continuations.removeAll { _ in true }
                }
            }
        }
    }

    // MARK: - CMWaterSubmersionManagerDelegate (all 4 methods are required)

    func manager(_ manager: CMWaterSubmersionManager, didUpdate event: CMWaterSubmersionEvent) {}

    func manager(_ manager: CMWaterSubmersionManager,
                 didUpdate measurement: CMWaterSubmersionMeasurement) {}

    func manager(_ manager: CMWaterSubmersionManager,
                 didUpdate temperature: CMWaterTemperature) {
        let celsius = temperature.temperature.converted(to: .celsius).value
        delegateQueue.async { [self] in
            self.latestTemp = celsius
            for c in self.continuations { c.yield(celsius) }
        }
    }

    func manager(_ manager: CMWaterSubmersionManager, errorOccurred error: Error) {}
}
