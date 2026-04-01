import Foundation

enum AppGroup {
    static let identifier = "group.com.cold.shared"

    static var sharedContainerURL: URL? {
        #if targetEnvironment(simulator)
        // App Groups require real signing entitlements — not available in simulator builds.
        // Fall back to NSTemporaryDirectory(), which is the same path for all apps
        // running as the same macOS user, giving us a shared store across Watch + iPhone sims.
        let dir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appending(path: identifier, directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
        #else
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
        #endif
    }

    static var storeURL: URL? {
        sharedContainerURL?.appending(path: "Cold.sqlite")
    }
}
