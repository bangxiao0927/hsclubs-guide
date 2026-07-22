import SwiftUI

struct SchoolDetailView: View {
    let school: School

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(school.availability.label)
                        .font(.caption.weight(.bold))
                        .textCase(.uppercase)
                        .foregroundStyle(availabilityColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(availabilityColor.opacity(0.12), in: Capsule())
                    Text(school.name)
                        .font(.system(.largeTitle, design: .serif).bold())
                        .foregroundStyle(GuideTheme.forest)
                    Label(school.location.displayName, systemImage: "mappin.and.ellipse")
                        .foregroundStyle(GuideTheme.muted)
                }

                HStack(spacing: 12) {
                    metric(title: "Clubs", value: school.clubCount.map(String.init) ?? "--")
                    metric(title: "Categories", value: String(school.categories.count))
                }

                if !school.categories.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Club categories")
                            .font(.headline)
                            .foregroundStyle(GuideTheme.forest)
                        ForEach(school.categories.sorted(by: { $0.key < $1.key }), id: \.key) { item in
                            HStack {
                                Text(item.key)
                                Spacer()
                                Text(String(item.value))
                                    .fontWeight(.semibold)
                            }
                            Divider()
                        }
                    }
                    .padding(18)
                    .background(.background, in: RoundedRectangle(cornerRadius: 20))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(GuideTheme.border)
                    }
                }

                Link(destination: school.canonicalURL) {
                    Label("Open school club site", systemImage: "arrow.up.right.square")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .background(GuideTheme.forest, in: RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityIdentifier("open-school-site")
                .accessibilityHint("Opens the independent website operated by this school")
                .disabled(school.availability == .suspended)

                Text("HSclubs Guide does not manage clubs, applications, memberships, or student accounts.")
                    .font(.footnote)
                    .foregroundStyle(GuideTheme.muted)
            }
            .padding()
        }
        .background(GuideTheme.background)
        .navigationTitle(school.shortName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func metric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title.bold())
                .foregroundStyle(GuideTheme.forest)
            Text(title)
                .font(.caption)
                .foregroundStyle(GuideTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(GuideTheme.paleGreen, in: RoundedRectangle(cornerRadius: 18))
    }

    private var availabilityColor: Color {
        switch school.availability {
        case .fresh: GuideTheme.forest
        case .stale: GuideTheme.amber
        case .unavailable, .suspended: .red
        }
    }
}
