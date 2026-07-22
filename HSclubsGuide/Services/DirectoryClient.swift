import Foundation

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
