import SwiftUI

struct DirectoryView: View {
    @StateObject private var viewModel: DirectoryViewModel

    init(client: any DirectoryClient) {
        _viewModel = StateObject(wrappedValue: DirectoryViewModel(client: client))
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("Loading schools")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(GuideTheme.background)
                case .failed(let message):
                    ContentUnavailableView {
                        Label("Directory unavailable", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Try again") { Task { await viewModel.load() } }
                            .buttonStyle(.borderedProminent)
                            .tint(GuideTheme.forest)
                    }
                    .background(GuideTheme.background)
                case .loaded:
                    schoolList
                }
            }
            .navigationTitle("HSclubs Guide")
            .searchable(text: $viewModel.searchText, prompt: "School, city, or region")
        }
        .tint(GuideTheme.forest)
        .task { await viewModel.load() }
    }

    private var schoolList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("SCHOOL DISCOVERY, MADE CLEAR")
                        .font(.caption.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(GuideTheme.amber)
                    Text("Find your school's club directory.")
                        .font(.system(.largeTitle, design: .serif).bold())
                        .foregroundStyle(GuideTheme.forest)
                        .accessibilityAddTraits(.isHeader)
                    Text("HSclubs Guide points students to verified, school-owned club sites.")
                        .font(.body)
                        .foregroundStyle(GuideTheme.muted)
                }
                .padding(.bottom, 8)

                if viewModel.filteredSchools.isEmpty {
                    ContentUnavailableView.search(text: viewModel.searchText)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else {
                    ForEach(viewModel.filteredSchools) { school in
                        NavigationLink(value: school.slug) {
                            SchoolCard(school: school)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("school-card-\(school.slug)")
                    }
                }
            }
            .padding()
        }
        .background(GuideTheme.background)
        .navigationDestination(for: String.self) { slug in
            if let school = viewModel.school(withSlug: slug) {
                SchoolDetailView(school: school)
            }
        }
    }
}
