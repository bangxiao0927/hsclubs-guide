import Foundation

enum DirectoryClientError: Error, Equatable {
    case invalidBaseURL
    case invalidResponse
}

protocol DirectoryClient: Sendable {
    func fetchSchools() async throws -> DirectoryResponse
}

struct FixtureDirectoryClient: DirectoryClient {
    let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func fetchSchools() async throws -> DirectoryResponse {
        let fixtureURL = bundle.url(
            forResource: "directory-schools.valid",
            withExtension: "json",
            subdirectory: "Fixtures"
        ) ?? bundle.url(forResource: "directory-schools.valid", withExtension: "json")

        guard let fixtureURL else {
            throw ContractError.invalidJSON
        }
        return try ContractDecoder.decodeDirectory(from: Data(contentsOf: fixtureURL))
    }
}

struct LiveDirectoryClient: DirectoryClient {
    private static let maximumResponseBytes = 256 * 1024

    private let session: any URLSessionProtocol
    private let schoolsURL: URL

    init?(baseURL: URL, session: any URLSessionProtocol = URLSession.shared) {
        guard baseURL.scheme == "https",
              baseURL.host() != nil,
              baseURL.user() == nil,
              baseURL.password() == nil
        else {
            return nil
        }

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.query = nil
        components?.fragment = nil

        guard let normalizedBaseURL = components?.url else { return nil }
        schoolsURL = normalizedBaseURL.appending(path: "api/v1/schools")
        self.session = session
    }

    func fetchSchools() async throws -> DirectoryResponse {
        var request = URLRequest(url: schoolsURL)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200 ... 299).contains(httpResponse.statusCode),
              httpResponse.value(forHTTPHeaderField: "Content-Type")?.lowercased()
              .contains("application/json") == true,
              data.count <= Self.maximumResponseBytes
        else {
            throw DirectoryClientError.invalidResponse
        }

        return try ContractDecoder.decodeDirectory(from: data)
    }
}
