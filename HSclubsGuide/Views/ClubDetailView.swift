import SwiftUI

/// Read-only detail page for a single club. Discovery only: no membership actions.
struct ClubDetailView: View {
    let club: Club

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    CategoryBadge(category: club.category)
                    Text(club.name)
                        .font(.largeTitle.bold())
                        .foregroundStyle(GuideTheme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                }

                Text(club.description)
                    .font(.body)
                    .foregroundStyle(GuideTheme.textPrimary)

                if hasInfoRows {
                    VStack(alignment: .leading, spacing: 0) {
                        if let advisor = club.advisor, !advisor.isEmpty {
                            infoRow(icon: "person", title: "Advisor", value: advisor)
                        }
                        if let location = club.location, !location.isEmpty {
                            infoRow(icon: "mappin.and.ellipse", title: "Room / Location", value: location)
                        }
                        if let schedule = club.meetingSchedule, !schedule.isEmpty {
                            infoRow(icon: "calendar", title: "Meeting schedule", value: schedule)
                        }
                    }
                    .padding(18)
                    .background(GuideTheme.cardSurface, in: RoundedRectangle(cornerRadius: 20))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(GuideTheme.border, lineWidth: 1)
                    }
                }

                if let instagramURL = club.instagramUrl {
                    Link(destination: instagramURL) {
                        Label("View on Instagram", systemImage: "arrow.up.right")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .background(GuideTheme.primary, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .accessibilityHint("Opens this club's Instagram page in your browser")
                }
            }
            .padding()
        }
        .background(GuideTheme.backgroundGradient)
        .navigationTitle(club.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hasInfoRows: Bool {
        [club.advisor, club.location, club.meetingSchedule]
            .contains { ($0?.isEmpty == false) }
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(GuideTheme.primary)
                    .frame(width: 22)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(GuideTheme.textMuted)
                    Text(value)
                        .font(.body)
                        .foregroundStyle(GuideTheme.textPrimary)
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 10)
        }
    }
}
