import SwiftUI
import SwiftData

@main
struct ColdApp: App {

    let container: ModelContainer = {
        let schema = Schema([IceBathSession.self])
        let url = AppGroup.storeURL ?? URL.applicationSupportDirectory
            .appending(path: "Cold.sqlite")
        let config = ModelConfiguration("ColdStore", schema: schema, url: url)
        return (try? ModelContainer(for: IceBathSession.self, configurations: config))
            ?? (try! ModelContainer(for: IceBathSession.self))
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
