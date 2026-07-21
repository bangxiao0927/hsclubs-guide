import SwiftUI

struct SchoolDetailView: View {
    let school: School

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Verified school directory", systemImage: "checkmark.seal.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.green)
                    Text(school.location.displayName)
                        .foregroundStyle(.secondary)
                    Text(school.availability.label)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(availabilityColor)
                }
                .padding(.vertical, 6)
            }

            if let clubCount = school.clubCount {
                Section("Directory summary") {
                    LabeledContent("Active public clubs", value: "\(clubCount)")
                    ForEach(school.categories.sorted(by: { $0.key < $1.key }), id: \.key) {
                        LabeledContent($0.key, value: "\($0.value)")
                    }
                }
            }

            Section {
                Link(destination: school.canonicalURL) {
                    Label("Open school club site", systemImage: "arrow.up.right.square")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fontWeight(.semibold)
                }
                .accessibilityIdentifier("open-school-site")
                .disabled(school.availability == .suspended)
            } footer: {
                Text("You will leave HSclubs Guide and open the website managed by this school.")
            }
        }
        .navigationTitle(school.shortName)
    }

    private var availabilityColor: Color {
        switch school.availability {
        case .fresh: .green
        case .stale: .orange
        case .unavailable, .suspended: .red
        }
    }
}
