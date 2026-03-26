import Foundation
import Observation
import SwiftData

/// State machine for a cold water immersion session.
///
/// Transitions:
///   idle → active (on start())
///   active → summary (on stop())
///   summary → idle (on reset())
@MainActor
@Observable
final class SessionViewModel {

    enum State {
        case idle
        case active(elapsed: TimeInterval, currentTemp: Double)
        case summary(IceBathSession)
    }

    private(set) var state: State = .idle

    // MARK: - Dependencies

    private let temperatureProvider: any TemperatureProviding
    private let runtimeManager: any ExtendedRuntimeManaging
    private let tickInterval: Duration

    // nonisolated(unsafe): timerTask is accessed in deinit which is nonisolated in Swift 6.
    nonisolated(unsafe) private var timerTask: Task<Void, Never>?
    nonisolated(unsafe) private var tempTask: Task<Void, Never>?

    // Accumulated during an active session
    private var sessionStart: Date?
    private var temperatureReadings: [TemperatureReading] = []
    private var latestTemp: Double = 0.0

    // MARK: - Init

    init(
        temperatureProvider: any TemperatureProviding,
        runtimeManager: any ExtendedRuntimeManaging,
        tickInterval: Duration = .seconds(1)
    ) {
        self.temperatureProvider = temperatureProvider
        self.runtimeManager = runtimeManager
        self.tickInterval = tickInterval
    }

    deinit {
        timerTask?.cancel()
        tempTask?.cancel()
    }

    // MARK: - Actions

    func start() {
        guard case .idle = state else { return }
        sessionStart = Date()
        temperatureReadings = []

        runtimeManager.start()
        startTimerLoop()
        startTemperatureLoop()
    }

    func stop() {
        guard case .active = state else { return }
        timerTask?.cancel()
        tempTask?.cancel()
        timerTask = nil
        tempTask = nil
        runtimeManager.stop()

        let duration = sessionStart.map { Date().timeIntervalSince($0) } ?? 0
        let session = IceBathSession(
            date: sessionStart ?? Date(),
            duration: duration,
            temperatureReadings: temperatureReadings
        )
        state = .summary(session)
    }

    func reset() {
        guard case .summary = state else { return }
        state = .idle
    }

    // MARK: - Private loops

    private func startTimerLoop() {
        let start = sessionStart ?? Date()
        timerTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(start)
                let temp = await self.temperatureProvider.currentTemperature()
                await MainActor.run {
                    if case .active = self.state {
                        self.state = .active(elapsed: elapsed, currentTemp: temp)
                    } else if case .idle = self.state {
                        // First tick: transition to active
                        self.state = .active(elapsed: elapsed, currentTemp: temp)
                    }
                }
                try? await Task.sleep(for: self.tickInterval)
            }
        }
    }

    private func startTemperatureLoop() {
        tempTask = Task { [weak self] in
            guard let self else { return }
            for await celsius in self.temperatureProvider.temperatureStream() {
                if Task.isCancelled { break }
                await MainActor.run {
                    self.latestTemp = celsius
                    self.temperatureReadings.append(
                        TemperatureReading(timestamp: Date(), celsius: celsius)
                    )
                }
            }
        }
    }
}
