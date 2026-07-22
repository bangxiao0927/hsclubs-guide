import Foundation

struct AppEnvironment: Sendable {
    private static let defaultDirectoryBaseURL = "https://api.guide.example.org"

    let directoryClient: any DirectoryClient

    init(bundle: Bundle = .main, forceFixtures: Bool = false) {
        let baseURLValue = ProcessInfo.processInfo.environment["DIRECTORY_API_BASE_URL"]
            ?? bundle.object(forInfoDictionaryKey: "DIRECTORY_API_BASE_URL") as? String
            ?? Self.defaultDirectoryBaseURL

        guard !forceFixtures,
              let baseURL = URL(string: baseURLValue),
              let client = LiveDirectoryClient(baseURL: baseURL)
        else {
            directoryClient = FixtureDirectoryClient(bundle: bundle)
            return
        }

        directoryClient = client
    }
}
