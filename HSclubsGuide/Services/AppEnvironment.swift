import Foundation

struct AppEnvironment: Sendable {
    let directoryClient: any DirectoryClient

    init(bundle: Bundle = .main) {
        directoryClient = FixtureDirectoryClient(bundle: bundle)
    }
}
