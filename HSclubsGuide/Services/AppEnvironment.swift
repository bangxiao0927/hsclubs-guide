import Foundation

struct AppEnvironment: Sendable {
    private static let defaultDirectoryBaseURL = "https://api.guide.example.org"

    let directoryClient: any DirectoryClient

    init(bundle: Bundle = .main) {
        guard let baseURLValue = Self.firstConfiguredValue(
            forKey: "DIRECTORY_API_BASE_URL",
            bundle: bundle
        ) else {
            directoryClient = FixtureDirectoryClient(bundle: bundle)
            return
        }

        guard let baseURL = URL(string: baseURLValue),
              let client = LiveDirectoryClient(baseURL: baseURL)
        else {
            directoryClient = FixtureDirectoryClient(bundle: bundle)
            return
        }

        directoryClient = client
    }

    private static func firstConfiguredValue(forKey key: String, bundle: Bundle) -> String? {
        if let value = ProcessInfo.processInfo.environment[key], !value.isEmpty {
            return value
        }
        return bundle.object(forInfoDictionaryKey: key) as? String
    }
}
