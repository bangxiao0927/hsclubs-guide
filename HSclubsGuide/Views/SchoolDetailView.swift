import SwiftUI

/// A school's browsable club directory ("mini-site"), mirroring hsclubs.net.
struct SchoolDetailView: View {
    @StateObject private var viewModel: SchoolClubsViewModel

    init(school: School, client: any DirectoryClient) {
        _viewModel = StateObject(
            wrappedValue: SchoolClubsViewModel(school: school, client: client)
        )
    }

    private var school: School { viewModel.school }

    /// Schools flagged unavailable/suspended have no browsable directory to show.
    private var isUnavailable: Bool {
        school.availability == .unavailable || school.availability == .suspended
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroCard

                if isUnavailable {
                    unavailableCard
                } else {
                    content
                }

                footer
            }
            .padding()
        }
        .background(GuideTheme.backgroundGradient)
        .navigationTitle(school.shortName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Club.self) { club in
            ClubDetailView(club: club)
        }
        .task {
            // Only reach out for club data when the directory is browsable.
            if !isUnavailable {
                await viewModel.load()
            }
        }
    }

    // MARK: Hero

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SCHOOL CLUB DIRECTORY")
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(GuideTheme.primary)
            Text(school.name)
                .font(.largeTitle.bold())
                .foregroundStyle(GuideTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Label(school.location.displayName, systemImage: "mappin.and.ellipse")
                .font(.subheadline)
                .foregroundStyle(GuideTheme.textMuted)

            HStack(spacing: 12) {
                statPill(title: "Active clubs", value: activeClubsValue)
                statPill(title: "Categories", value: categoriesValue)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(GuideTheme.cardSurface, in: RoundedRectangle(cornerRadius: 28))
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .stroke(GuideTheme.border, lineWidth: 1)
        }
        .shadow(color: GuideTheme.primary.opacity(0.12), radius: 18, y: 10)
    }

    /// The active-clubs stat prefers live loaded data, falling back to directory metadata.
    private var activeClubsValue: String {
        if case let .loaded(clubs) = viewModel.state {
            return String(clubs.count)
        }
        return school.clubCount.map(String.init) ?? "--"
    }

    private var categoriesValue: String {
        if case .loaded = viewModel.state {
            return String(viewModel.categoryCounts.count)
        }
        return String(school.categories.count)
    }

    private func statPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title.bold())
                .foregroundStyle(GuideTheme.primary)
            Text(title)
                .font(.caption)
                .foregroundStyle(GuideTheme.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(GuideTheme.primarySoft, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: Content states

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Loading clubs")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
        case .failed(let message):
            ContentUnavailableView {
                Label("Clubs unavailable", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try again") { Task { await viewModel.load() } }
                    .buttonStyle(.borderedProminent)
                    .tint(GuideTheme.primary)
            }
        case .loaded:
            loadedContent
        }
    }

    @ViewBuilder
    private var loadedContent: some View {
        searchField
        categoryChips
        clubList
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(GuideTheme.textMuted)
            TextField(
                "Search clubs, advisors, categories, or keywords",
                text: $viewModel.searchText
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(GuideTheme.cardSurface, in: Capsule())
        .overlay {
            Capsule().stroke(GuideTheme.border, lineWidth: 1)
        }
        .accessibilityIdentifier("club-search")
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryChip(title: "All clubs", isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                }
                ForEach(viewModel.categoryCounts, id: \.name) { entry in
                    categoryChip(
                        title: "\(entry.name) (\(entry.count))",
                        isSelected: viewModel.selectedCategory == entry.name
                    ) {
                        // Tapping the active chip clears the filter.
                        if viewModel.selectedCategory == entry.name {
                            viewModel.selectedCategory = nil
                        } else {
                            viewModel.selectedCategory = entry.name
                        }
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func categoryChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? Color.white : GuideTheme.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    isSelected ? GuideTheme.primary : GuideTheme.chipInactiveBg,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var clubList: some View {
        if viewModel.filteredClubs.isEmpty {
            ContentUnavailableView.search(text: viewModel.searchText)
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
        } else {
            LazyVStack(spacing: 14) {
                ForEach(viewModel.filteredClubs) { club in
                    NavigationLink(value: club) {
                        ClubCard(club: club)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("club-card-\(club.id)")
                }
            }
        }
    }

    // MARK: Unavailable + footer

    private var unavailableCard: some View {
        ContentUnavailableView {
            Label(school.availability.label, systemImage: "clock.badge.exclamationmark")
        } description: {
            Text("This school's club directory is not available right now. Please check back later.")
        }
        .padding(.vertical, 20)
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 12) {
            Link(destination: school.canonicalURL) {
                Label("Open \(school.shortName) club site", systemImage: "arrow.up.right.square")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .fontWeight(.semibold)
                    .foregroundStyle(GuideTheme.primary)
                    .background(GuideTheme.primarySoft, in: RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(GuideTheme.border, lineWidth: 1)
                    }
            }
            .accessibilityIdentifier("open-school-site")
            .accessibilityHint("Opens the independent website operated by this school")
            .disabled(school.availability == .suspended)

            Text("HSclubs Guide does not manage clubs, applications, memberships, or student accounts.")
                .font(.footnote)
                .foregroundStyle(GuideTheme.textMuted)
        }
    }
}
