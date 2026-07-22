import SwiftUI

@main
struct HSclubsGuideApp: App {
    private let environment: AppEnvironment

    init() {
        let forceFixtures = ProcessInfo.processInfo.environment["USE_FIXTURE_DIRECTORY"] == "true"
            || ProcessInfo.processInfo.arguments.contains("--use-fixture-directory")
        environment = AppEnvironment(forceFixtures: forceFixtures)
    }

    var body: some Scene {
        WindowGroup {
            DirectoryView(client: environment.directoryClient)
        }
    }
}
