import XCTest
@testable import HSclubsGuide

@MainActor
final class DirectoryViewModelTests: XCTestCase {
    func testSearchMatchesNameAbbreviationAndLocation() async {
        let school = makeSchool()
        let viewModel = DirectoryViewModel(client: StubClient(response: response(with: [school])))
        await viewModel.load()

        for query in ["mountain", "mvhs", "CA"] {
            viewModel.searchText = query
            XCTAssertEqual(viewModel.filteredSchools.map(\.slug), ["mountain-view"])
        }
    }

    func testSearchIgnoresWhitespaceAndCase() async {
        let viewModel = DirectoryViewModel(client: StubClient(response: response(with: [makeSchool()])))
        await viewModel.load()
        viewModel.searchText = "  MoUnTaIn  "

        XCTAssertEqual(viewModel.filteredSchools.count, 1)
    }

    func testFailureShowsSafeMessage() async {
        let viewModel = DirectoryViewModel(client: StubClient(error: ContractError.invalidJSON))
        await viewModel.load()

        guard case let .failed(message) = viewModel.state else {
            return XCTFail("Expected failed state")
        }
        XCTAssertEqual(message, "School information could not be loaded. Please try again.")
    }

    private func response(with schools: [School]) -> DirectoryResponse {
        DirectoryResponse(schemaVersion: "1.0", generatedAt: Date(), schools: schools)
    }

    private func makeSchool() -> School {
        School(
            slug: "mountain-view",
            name: "Mountain View High School",
            shortName: "MVHS",
            canonicalURL: URL(string: "https://clubs.example.org")!,
            location: SchoolLocation(city: "Mountain View", region: "CA", country: "US"),
            verificationStatus: "verified",
            availability: .fresh,
            clubCount: 42,
            categories: ["Academic": 12],
            sourceUpdatedAt: Date(),
            lastSuccessfulCollectionAt: Date()
        )
    }
}

private struct StubClient: DirectoryClient {
    let result: Result<DirectoryResponse, Error>

    init(response: DirectoryResponse) {
        result = .success(response)
    }

    init(error: Error) {
        result = .failure(error)
    }

    func fetchSchools() async throws -> DirectoryResponse {
        try result.get()
    }

    func fetchClubs(forSlug slug: String) async throws -> SchoolClubsResponse {
        SchoolClubsResponse(schemaVersion: "1.0", slug: slug, generatedAt: Date(), clubs: [])
    }
}
