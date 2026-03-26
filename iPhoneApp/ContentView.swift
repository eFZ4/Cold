import SwiftUI

// READ-ONLY companion view — this target may NEVER write sessions to the shared store.
// All session creation happens exclusively on the Watch target.
struct ContentView: View {
    var body: some View {
        NavigationStack {
            Text(String(localized: "session_history_placeholder"))
                .navigationTitle(String(localized: "app_name"))
        }
    }
}
