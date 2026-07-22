import XCTest
@testable import HSclubsGuide

@MainActor
final class SchoolClubsViewModelTests: XCTestCase {
    func testCategoryFilterNarrowsResults() async {
        let viewModel = makeViewModel(clubs: sampleClubs)
        await viewModel.load()

        viewModel.selectedCategory = "Sports"
        XCTAssertEqual(viewModel.filteredClubs.map(\.name), ["Track Club"])

        viewModel.selectedCategory = nil
        XCTAssertEqual(viewModel.filteredClubs.count, 3)
    }

    func testSearchMatchesNameAdvisorCategoryAndDescription() async {
        let viewModel = makeViewModel(clubs: sampleClubs)
        await viewModel.load()

        viewModel.searchText = "chess"            // name
        XCTAssertEqual(viewModel.filteredClubs.map(\.name), ["Chess Club"])

        viewModel.searchText = "bowen"            // advisor
        XCTAssertEqual(viewModel.filteredClubs.map(\.name), ["Chess Club"])

        viewModel.searchText = "sports"           // category
        XCTAssertEqual(viewModel.filteredClubs.map(\.name), ["Track Club"])

        viewModel.searchText = "microscope"       // description keyword
        XCTAssertEqual(viewModel.filteredClubs.map(\.name), ["Science Club"])
    }

    func testCategoryCountsAreSortedWithCorrectTotals() async {
        let viewModel = makeViewModel(clubs: sampleClubs)
        await viewModel.load()

        let counts = viewModel.categoryCounts
        XCTAssertEqual(counts.map(\.name), ["Sports", "STEM", "Strategy"])
        XCTAssertTrue(counts.allSatisfy { $0.count == 1 })
    }

    func testFailureSetsSafeMessage() async {
        let viewModel = makeViewModel(error: ContractError.invalidJSON)
        await viewModel.load()

        guard case let .failed(message) = viewModel.state else {
            return XCTFail("Expected failed state")
        }
        XCTAssertEqual(message, "This school's club directory could not be loaded.")
    }

    // MARK: Helpers

    private var sampleClubs: [Club] {
        [
            Club(
                id: 1, name: "Chess Club", category: "Strategy", advisor: "Nathan Bowen",
                location: "725", meetingSchedule: "Monday", description: "Play chess.",
                instagramUrl: nil
            ),
            Club(
                id: 2, name: "Track Club", category: "Sports", advisor: "Sam Okafor",
                location: "Field", meetingSchedule: "Tuesday", description: "Run fast.",
                instagramUrl: nil
            ),
            Club(
                id: 3, name: "Science Club", category: "STEM", advisor: "Ana Diaz",
                location: "Lab", meetingSchedule: "Wednesday",
                description: "Explore biology with a microscope.", instagramUrl: nil
            ),
        ]
    }

    private func makeViewModel(clubs: [Club]) -> SchoolClubsViewModel {
        SchoolClubsViewModel(school: makeSchool(), client: ClubsStubClient(clubs: clubs))
    }

    private func makeViewModel(error: Error) -> SchoolClubsViewModel {
        SchoolClubsViewModel(school: makeSchool(), client: ClubsStubClient(error: error))
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
            clubCount: 3,
            categories: ["Strategy": 1, "Sports": 1, "STEM": 1],
            sourceUpdatedAt: Date(),
            lastSuccessfulCollectionAt: Date()
        )
    }
}

private struct ClubsStubClient: DirectoryClient {
    let clubsResult: Result<[Club], Error>

    init(clubs: [Club]) {
        clubsResult = .success(clubs)
    }

    init(error: Error) {
        clubsResult = .failure(error)
    }

    func fetchSchools() async throws -> DirectoryResponse {
        DirectoryResponse(schemaVersion: "1.0", generatedAt: Date(), schools: [])
    }

    func fetchClubs(forSlug slug: String) async throws -> SchoolClubsResponse {
        let clubs = try clubsResult.get()
        return SchoolClubsResponse(schemaVersion: "1.0", slug: slug, generatedAt: Date(), clubs: clubs)
    }
}
