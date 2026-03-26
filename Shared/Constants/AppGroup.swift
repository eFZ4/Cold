import Foundation

enum AppGroup {
    static let identifier = "group.com.cold.shared"

    static var sharedContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }

    static var storeURL: URL? {
        sharedContainerURL?.appendingPathComponent("Cold.sqlite")
    }
}
