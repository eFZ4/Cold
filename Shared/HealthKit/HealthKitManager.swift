import Foundation
import HealthKit

/// Saves cold water immersion sessions to HealthKit.
/// Requested types: HKWorkoutType (waterSports), HKQuantityType(.waterTemperature).
/// No other types are requested — scope is intentionally minimal.
final class HealthKitManager: HealthKitManaging, @unchecked Sendable {

    private let store = HKHealthStore()

    // MARK: - Types

    private var writeTypes: Set<HKSampleType> {
        var types: Set<HKSampleType> = [HKObjectType.workoutType()]
        if let tempType = HKQuantityType.quantityType(forIdentifier: .waterTemperature) {
            types.insert(tempType)
        }
        return types
    }

    private var readTypes: Set<HKObjectType> {
        var types: Set<HKObjectType> = [HKObjectType.workoutType()]
        if let tempType = HKQuantityType.quantityType(forIdentifier: .waterTemperature) {
            types.insert(tempType)
        }
        return types
    }

    // MARK: - HealthKitManaging

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        try await store.requestAuthorization(toShare: writeTypes, read: readTypes)
    }

    func saveSession(_ session: IceBathSession) async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let startDate = session.date
        let endDate = startDate.addingTimeInterval(session.duration)

        // Build workout
        let workoutBuilder = HKWorkoutBuilder(
            healthStore: store,
            configuration: workoutConfiguration(),
            device: .local()
        )

        try await workoutBuilder.beginCollection(at: startDate)

        // Add water temperature samples
        let tempSamples = temperatureSamples(from: session.temperatureReadings)
        if !tempSamples.isEmpty {
            try await workoutBuilder.addSamples(tempSamples)
        }

        try await workoutBuilder.endCollection(at: endDate)
        try await workoutBuilder.finishWorkout()
    }

    // MARK: - Private helpers

    private func workoutConfiguration() -> HKWorkoutConfiguration {
        let config = HKWorkoutConfiguration()
        config.activityType = .waterSports
        config.locationType = .outdoor
        return config
    }

    private func temperatureSamples(from readings: [TemperatureReading]) -> [HKQuantitySample] {
        guard let tempType = HKQuantityType.quantityType(forIdentifier: .waterTemperature) else {
            return []
        }
        return readings.map { reading in
            let quantity = HKQuantity(unit: .degreeCelsius(), doubleValue: reading.celsius)
            return HKQuantitySample(
                type: tempType,
                quantity: quantity,
                start: reading.timestamp,
                end: reading.timestamp
            )
        }
    }
}
