import SwiftUI

struct ContentView: View {
    @State var viewModel: SessionViewModel

    var body: some View {
        switch viewModel.state {
        case .idle:
            IdleView(onStart: { viewModel.start() })
        case let .active(elapsed, currentTemp):
            ActiveSessionView(
                elapsed: elapsed,
                currentTemp: currentTemp,
                onStop: { viewModel.stop() }
            )
        case let .summary(session):
            SessionSummaryView(
                session: session,
                onDone: { viewModel.reset() }
            )
        }
    }
}

// MARK: - Idle

private struct IdleView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "thermometer.snowflake")
                .font(.system(size: 36))
                .foregroundStyle(.cyan)

            Button(action: onStart) {
                Text(String(localized: "start_session"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
        }
        .padding()
    }
}

// MARK: - Active session

private struct ActiveSessionView: View {
    let elapsed: TimeInterval
    let currentTemp: Double
    let onStop: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(formattedElapsed)
                .font(.system(size: 40, weight: .semibold, design: .monospaced))
                .minimumScaleFactor(0.6)

            HStack(spacing: 4) {
                Image(systemName: "thermometer.medium")
                    .foregroundStyle(.cyan)
                Text(String(format: "%.1f°C", currentTemp))
                    .font(.title3)
            }

            Spacer(minLength: 4)

            Button(action: onStop) {
                Text(String(localized: "stop_session"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
    }

    private var formattedElapsed: String {
        let mins = Int(elapsed) / 60
        let secs = Int(elapsed) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
