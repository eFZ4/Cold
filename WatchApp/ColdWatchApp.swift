import SwiftUI
import SwiftData

@main
struct ColdWatchApp: App {

    let container: ModelContainer = {
        let schema = Schema([IceBathSession.self])
        let url = AppGroup.storeURL ?? URL.applicationSupportDirectory
            .appending(path: "Cold.sqlite")
        let config = ModelConfiguration("ColdStore", schema: schema, url: url)
        return (try? ModelContainer(for: IceBathSession.self, configurations: config))
            ?? (try! ModelContainer(for: IceBathSession.self))
    }()

    @State private var viewModel: SessionViewModel = {
        let provider = TemperatureProviderFactory.makeProvider()
        let runtime = ExtendedRuntimeManager()
        return SessionViewModel(temperatureProvider: provider, runtimeManager: runtime)
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
        .modelContainer(container)
    }
}
