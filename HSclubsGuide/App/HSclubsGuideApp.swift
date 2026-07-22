import SwiftUI

@main
struct HSclubsGuideApp: App {
    private let environment: AppEnvironment

    init() {
        environment = AppEnvironment(
            forceFixtures: ProcessInfo.processInfo.environment["USE_FIXTURE_DIRECTORY"] == "true"
        )
    }

    var body: some Scene {
        WindowGroup {
            DirectoryView(client: environment.directoryClient)
        }
    }
}
