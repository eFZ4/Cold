import SwiftUI

struct SessionSummaryView: View {
    let session: IceBathSession
    let onDone: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text(String(localized: "summary_title"))
                    .font(.headline)

                summaryRow(
                    label: String(localized: "summary_duration"),
                    value: formattedDuration
                )

                if !session.temperatureReadings.isEmpty {
                    summaryRow(
                        label: String(localized: "summary_min_temp"),
                        value: formattedTemp(session.minTemperature)
                    )
                    summaryRow(
                        label: String(localized: "summary_max_temp"),
                        value: formattedTemp(session.maxTemperature)
                    )
                    summaryRow(
                        label: String(localized: "summary_avg_temp"),
                        value: formattedTemp(session.averageTemperature)
                    )
                }

                Button(action: onDone) {
                    Text(String(localized: "summary_done"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
                .padding(.top, 4)
            }
            .padding()
        }
    }

    // MARK: - Helpers

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
                .font(.caption)
            Spacer()
            Text(value)
                .font(.caption.weight(.semibold))
        }
    }

    private var formattedDuration: String {
        let mins = Int(session.duration) / 60
        let secs = Int(session.duration) % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    private func formattedTemp(_ temp: Double?) -> String {
        guard let t = temp else {
            return String(localized: "summary_no_data")
        }
        return String(format: "%.1f°C", t)
    }
}
