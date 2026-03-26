import SwiftUI
import SwiftData

@main
struct ColdWatchApp: App {

    @State private var viewModel: SessionViewModel = {
        let provider = TemperatureProviderFactory.makeProvider()
        let runtime = ExtendedRuntimeManager()
        return SessionViewModel(temperatureProvider: provider, runtimeManager: runtime)
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
