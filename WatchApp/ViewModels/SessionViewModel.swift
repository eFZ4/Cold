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
    private let healthKitManager: any HealthKitManaging
    private let tickInterval: Duration

    private var timerTask: Task<Void, Never>?
    private var tempTask: Task<Void, Never>?

    // Accumulated during an active session
    private var sessionStart: Date?
    private var temperatureReadings: [TemperatureReading] = []

    // MARK: - Init

    init(
        temperatureProvider: any TemperatureProviding,
        runtimeManager: any ExtendedRuntimeManaging,
        healthKitManager: any HealthKitManaging = HealthKitManager(),
        tickInterval: Duration = .seconds(1)
    ) {
        self.temperatureProvider = temperatureProvider
        self.runtimeManager = runtimeManager
        self.healthKitManager = healthKitManager
        self.tickInterval = tickInterval
    }

    // MARK: - Actions

    func start() {
        guard case .idle = state else { return }
        sessionStart = Date()
        temperatureReadings = []

        Task { [weak self] in
            try? await self?.healthKitManager.requestAuthorization()
        }

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

        Task { [weak self] in
            try? await self?.healthKitManager.saveSession(session)
        }

        state = .summary(session)
    }

    func reset() {
        guard case .summary = state else { return }
        state = .idle
    }

    // MARK: - Private loops

    private func startTimerLoop() {
        let start = sessionStart ?? Date()
        timerTask = Task { [weak self, tickInterval] in
            // Check self on every iteration — loop exits naturally when self deallocates
            while !Task.isCancelled {
                guard let self else { return }
                let elapsed = Date().timeIntervalSince(start)
                let temp = await self.temperatureProvider.currentTemperature()
                await MainActor.run {
                    switch self.state {
                    case .idle, .active:
                        self.state = .active(elapsed: elapsed, currentTemp: temp)
                    case .summary:
                        break
                    }
                }
                try? await Task.sleep(for: tickInterval)
            }
        }
    }

    private func startTemperatureLoop() {
        tempTask = Task { [weak self] in
            guard let self else { return }
            for await celsius in self.temperatureProvider.temperatureStream() {
                if Task.isCancelled { break }
                self.temperatureReadings.append(
                    TemperatureReading(timestamp: Date(), celsius: celsius)
                )
            }
        }
    }
}
