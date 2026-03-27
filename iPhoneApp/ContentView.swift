import SwiftUI
import SwiftData

// READ-ONLY companion view — this target may NEVER write sessions to the shared store.
// All session creation happens exclusively on the Watch target.
struct ContentView: View {
    @Query(sort: \IceBathSession.date, order: .reverse) private var sessions: [IceBathSession]

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    ContentUnavailableView(
                        String(localized: "app_name"),
                        systemImage: "thermometer.snowflake",
                        description: Text(String(localized: "session_history_placeholder"))
                    )
                } else {
                    List(sessions) { session in
                        SessionRow(session: session)
                    }
                }
            }
            .navigationTitle(String(localized: "app_name"))
        }
    }
}

// MARK: - Session row

private struct SessionRow: View {
    let session: IceBathSession

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(session.date, style: .date)
                    .font(.headline)
                Spacer()
                Text(formattedDuration)
                    .font(.headline)
                    .monospacedDigit()
            }
            HStack(spacing: 16) {
                if let avg = session.averageTemperature {
                    Label(String(format: "%.1f°C", avg), systemImage: "thermometer.medium")
                        .font(.subheadline)
                        .foregroundStyle(.cyan)
                }
                if let min = session.minTemperature {
                    Text(String(format: "↓%.1f°C", min))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if let max = session.maxTemperature {
                    Text(String(format: "↑%.1f°C", max))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }

    private var formattedDuration: String {
        let mins = Int(session.duration) / 60
        let secs = Int(session.duration) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
