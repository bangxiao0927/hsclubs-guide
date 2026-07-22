import Foundation

protocol DirectoryClient: Sendable {
    func fetchSchools() async throws -> DirectoryResponse
    func fetchClubs(forSlug slug: String) async throws -> SchoolClubsResponse
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

    func fetchClubs(forSlug slug: String) async throws -> SchoolClubsResponse {
        let resource = "school-clubs.\(slug).valid"
        let fixtureURL = bundle.url(
            forResource: resource,
            withExtension: "json",
            subdirectory: "Fixtures"
        ) ?? bundle.url(forResource: resource, withExtension: "json")

        // A missing fixture means this school's directory is unavailable.
        guard let fixtureURL else {
            throw ContractError.invalidJSON
        }
        return try ContractDecoder.decodeSchoolClubs(from: Data(contentsOf: fixtureURL))
    }
}
