import Foundation
import SwiftData

// MARK: - TemperatureReading

struct TemperatureReading: Codable, Sendable, Equatable {
    let timestamp: Date
    let celsius: Double
}

// MARK: - IceBathSession

@Model
final class IceBathSession {
    var id: UUID
    var date: Date
    /// Duration in seconds
    var duration: TimeInterval
    /// Temperature readings sampled during the session.
    /// Stored as a Codable array — SwiftData encodes this via JSON.
    var temperatureReadings: [TemperatureReading]
    var notes: String?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        duration: TimeInterval = 0,
        temperatureReadings: [TemperatureReading] = [],
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.temperatureReadings = temperatureReadings
        self.notes = notes
    }
}

// MARK: - Computed aggregates

extension IceBathSession {
    var averageTemperature: Double? {
        guard !temperatureReadings.isEmpty else { return nil }
        let sum = temperatureReadings.reduce(0.0) { $0 + $1.celsius }
        return sum / Double(temperatureReadings.count)
    }

    var minTemperature: Double? {
        temperatureReadings.map(\.celsius).min()
    }

    var maxTemperature: Double? {
        temperatureReadings.map(\.celsius).max()
    }
}
