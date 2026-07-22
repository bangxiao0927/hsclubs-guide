import Combine
import Foundation

/// Drives a single school's club directory ("mini-site") screen.
/// It is intentionally separate from `DirectoryViewModel`, which owns the
/// top-level list of schools.
@MainActor
final class SchoolClubsViewModel: ObservableObject {
    enum State {
        case loading
        case loaded([Club])
        case failed(String)
    }

    @Published private(set) var state: State = .loading
    @Published var searchText = ""
    @Published var selectedCategory: String?   // nil represents the "All clubs" filter.

    let school: School
    private let client: any DirectoryClient

    init(school: School, client: any DirectoryClient) {
        self.school = school
        self.client = client
    }

    /// Every loaded club, or an empty array while loading or on failure.
    private var allClubs: [Club] {
        guard case let .loaded(clubs) = state else { return [] }
        return clubs
    }

    /// Distinct categories with how many clubs fall under each, sorted by name.
    var categoryCounts: [(name: String, count: Int)] {
        var counts: [String: Int] = [:]
        for club in allClubs {
            counts[club.category, default: 0] += 1
        }
        return counts
            .map { (name: $0.key, count: $0.value) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    /// Clubs after applying the selected category and the free-text search.
    var filteredClubs: [Club] {
        var clubs = allClubs

        if let selectedCategory {
            clubs = clubs.filter { $0.category == selectedCategory }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return clubs }

        return clubs.filter { club in
            [club.name, club.advisor ?? "", club.category, club.description]
                .contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    /// A small, deterministic set of highlighted clubs for the "Featured clubs"
    /// row, mirroring the highlighted section on hsclubs.net. Clubs with an
    /// Instagram link are preferred as a lightweight signal of an active club;
    /// ties fall back to fixture order for stable, testable output.
    var featuredClubs: [Club] {
        let maximumFeatured = 5
        let ordered = allClubs.enumerated().sorted { lhs, rhs in
            let lhsHasLink = lhs.element.instagramUrl != nil
            let rhsHasLink = rhs.element.instagramUrl != nil
            if lhsHasLink != rhsHasLink {
                return lhsHasLink && !rhsHasLink
            }
            return lhs.offset < rhs.offset
        }
        return ordered.prefix(maximumFeatured).map(\.element)
    }

    /// Featured clubs are only relevant on the unfiltered, unsearched directory.
    var showsFeaturedClubs: Bool {
        selectedCategory == nil
            && searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && featuredClubs.count > 1
    }

    func load() async {
        state = .loading
        do {
            let response = try await client.fetchClubs(forSlug: school.slug)
            state = .loaded(response.clubs)
        } catch {
            state = .failed("This school's club directory could not be loaded.")
        }
    }
}
