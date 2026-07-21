import SwiftUI

@main
struct HSclubsGuideApp: App {
    var body: some Scene {
        WindowGroup {
            DirectoryView(client: FixtureDirectoryClient())
        }
    }
}
