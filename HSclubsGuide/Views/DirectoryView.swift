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
                case .failed(let message):
                    ContentUnavailableView {
                        Label("Directory unavailable", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Try again") { Task { await viewModel.load() } }
                    }
                case .loaded:
                    schoolList
                }
            }
            .navigationTitle("HSclubs Guide")
            .searchable(text: $viewModel.searchText, prompt: "School, city, or region")
        }
        .tint(Color("AccentColor"))
        .task { await viewModel.load() }
    }

    private var schoolList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Find your school")
                        .font(.largeTitle.bold())
                        .accessibilityAddTraits(.isHeader)
                    Text("Open a verified, school-owned club directory.")
                        .font(.body)
                        .foregroundStyle(.secondary)
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
        .background(Color.secondary.opacity(0.08))
        .navigationDestination(for: String.self) { slug in
            if let school = viewModel.school(withSlug: slug) {
                SchoolDetailView(school: school)
            }
        }
    }
}
