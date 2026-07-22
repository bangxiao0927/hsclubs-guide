import SwiftUI

/// A tappable summary card for a single club, mirroring the hsclubs.net club list item.
struct ClubCard: View {
    let club: Club

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                CategoryBadge(category: club.category)
                Spacer(minLength: 8)
                if club.instagramUrl != nil {
                    Image(systemName: "link")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(GuideTheme.primary)
                        .accessibilityLabel("Has an Instagram link")
                }
            }

            Text(club.name)
                .font(.headline.bold())
                .foregroundStyle(GuideTheme.textPrimary)

            VStack(alignment: .leading, spacing: 6) {
                if let advisor = club.advisor, !advisor.isEmpty {
                    metadataRow(icon: "person", text: advisor)
                }
                if let schedule = club.meetingSchedule, !schedule.isEmpty {
                    metadataRow(icon: "calendar", text: schedule)
                }
                if let location = club.location, !location.isEmpty {
                    metadataRow(icon: "mappin.and.ellipse", text: location)
                }
            }

            Text(club.description)
                .font(.subheadline)
                .foregroundStyle(GuideTheme.textMuted)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(GuideTheme.cardSurface, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(GuideTheme.border, lineWidth: 1)
        }
        .shadow(color: GuideTheme.primary.opacity(0.12), radius: 16, y: 8)
    }

    private func metadataRow(icon: String, text: String) -> some View {
        Label {
            Text(text)
                .foregroundStyle(GuideTheme.textMuted)
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(GuideTheme.primary)
        }
        .font(.footnote)
    }
}

/// A small blue-tinted pill showing a club's category.
struct CategoryBadge: View {
    let category: String

    var body: some View {
        Text(category)
            .font(.caption.weight(.semibold))
            .foregroundStyle(GuideTheme.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(GuideTheme.primarySoft, in: Capsule())
    }
}
