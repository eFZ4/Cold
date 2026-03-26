import XCTest
import SwiftData
@testable import ColdWatch

final class IceBathSessionTests: XCTestCase {

    // MARK: - Model container (in-memory only — App Group not available in tests)

    private var container: ModelContainer!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: IceBathSession.self, configurations: config)
    }

    override func tearDownWithError() throws {
        container = nil
    }

    // MARK: - Init

    func test_init_defaultsAreCorrect() {
        let session = IceBathSession()
        XCTAssertNotNil(session.id)
        XCTAssertTrue(session.temperatureReadings.isEmpty)
        XCTAssertNil(session.notes)
        XCTAssertEqual(session.duration, 0)
    }

    func test_init_withValues() {
        let date = Date()
        let session = IceBathSession(date: date, duration: 120, notes: "Cold today")
        XCTAssertEqual(session.date, date)
        XCTAssertEqual(session.duration, 120)
        XCTAssertEqual(session.notes, "Cold today")
    }

    // MARK: - Temperature aggregates

    func test_averageTemperature_emptyReadings_returnsNil() {
        let session = IceBathSession()
        XCTAssertNil(session.averageTemperature)
    }

    func test_averageTemperature_singleReading() throws {
        var session = IceBathSession()
        session.temperatureReadings = [TemperatureReading(timestamp: Date(), celsius: 10.0)]
        let avg = try XCTUnwrap(session.averageTemperature)
        XCTAssertEqual(avg, 10.0, accuracy: 0.001)
    }

    func test_averageTemperature_multipleReadings() throws {
        var session = IceBathSession()
        session.temperatureReadings = [
            TemperatureReading(timestamp: Date(), celsius: 6.0),
            TemperatureReading(timestamp: Date(), celsius: 8.0),
            TemperatureReading(timestamp: Date(), celsius: 10.0),
        ]
        let avg = try XCTUnwrap(session.averageTemperature)
        XCTAssertEqual(avg, 8.0, accuracy: 0.001)
    }

    func test_minTemperature_returnsLowest() throws {
        var session = IceBathSession()
        session.temperatureReadings = [
            TemperatureReading(timestamp: Date(), celsius: 6.0),
            TemperatureReading(timestamp: Date(), celsius: 3.5),
            TemperatureReading(timestamp: Date(), celsius: 8.0),
        ]
        let min = try XCTUnwrap(session.minTemperature)
        XCTAssertEqual(min, 3.5, accuracy: 0.001)
    }

    func test_maxTemperature_returnsHighest() throws {
        var session = IceBathSession()
        session.temperatureReadings = [
            TemperatureReading(timestamp: Date(), celsius: 6.0),
            TemperatureReading(timestamp: Date(), celsius: 3.5),
            TemperatureReading(timestamp: Date(), celsius: 8.0),
        ]
        let max = try XCTUnwrap(session.maxTemperature)
        XCTAssertEqual(max, 8.0, accuracy: 0.001)
    }

    func test_minMaxTemperature_emptyReadings_returnNil() {
        let session = IceBathSession()
        XCTAssertNil(session.minTemperature)
        XCTAssertNil(session.maxTemperature)
    }

    // MARK: - TemperatureReading Codable

    func test_temperatureReading_codableRoundtrip() throws {
        let original = TemperatureReading(timestamp: Date(timeIntervalSince1970: 1_000_000), celsius: 7.5)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(TemperatureReading.self, from: data)
        XCTAssertEqual(decoded.celsius, original.celsius, accuracy: 0.001)
        XCTAssertEqual(decoded.timestamp.timeIntervalSince1970,
                       original.timestamp.timeIntervalSince1970,
                       accuracy: 0.001)
    }

    // MARK: - Persistence

    func test_session_persistsToInMemoryStore() throws {
        let context = ModelContext(container)
        let session = IceBathSession(date: Date(), duration: 60, notes: nil)
        context.insert(session)
        try context.save()

        let descriptor = FetchDescriptor<IceBathSession>()
        let results = try context.fetch(descriptor)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].duration, 60)
    }
}
