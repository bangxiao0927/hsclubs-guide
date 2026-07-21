import Combine
import Foundation

@MainActor
final class DirectoryViewModel: ObservableObject {
    enum State {
        case loading
        case loaded([School])
        case failed(String)
    }

    @Published private(set) var state: State = .loading
    @Published var searchText = ""

    private let client: any DirectoryClient

    init(client: any DirectoryClient) {
        self.client = client
    }

    var filteredSchools: [School] {
        guard case let .loaded(schools) = state else { return [] }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return schools }

        return schools.filter { school in
            [school.name, school.shortName, school.location.city, school.location.region]
                .contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    func school(withSlug slug: String) -> School? {
        guard case let .loaded(schools) = state else { return nil }
        return schools.first { $0.slug == slug }
    }

    func load() async {
        state = .loading
        do {
            state = .loaded(try await client.fetchSchools().schools)
        } catch {
            state = .failed("School information could not be loaded. Please try again.")
        }
    }
}
