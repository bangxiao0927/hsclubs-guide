import SwiftUI

@main
struct HSclubsGuideApp: App {
    private let environment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            DirectoryView(client: environment.directoryClient)
        }
    }
}
