import SwiftUI

struct SchoolCard: View {
    let school: School

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(GuideTheme.primarySoft)
                    Text(school.shortName.prefix(3))
                        .font(.caption.bold())
                        .foregroundStyle(GuideTheme.primary)
                }
                .frame(width: 48, height: 48)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(school.name)
                        .font(.headline)
                        .foregroundStyle(GuideTheme.textPrimary)
                    Text(school.location.displayName)
                        .font(.subheadline)
                        .foregroundStyle(GuideTheme.textMuted)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(GuideTheme.primary.opacity(0.6))
            }

            HStack {
                Label("Verified", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(GuideTheme.primary)
                Spacer()
                if let clubCount = school.clubCount {
                    Text("\(clubCount) clubs")
                        .foregroundStyle(GuideTheme.textMuted)
                }
            }
            .font(.caption.weight(.semibold))

            Text(school.availability.label)
                .font(.caption)
                .foregroundStyle(availabilityColor)
        }
        .padding(16)
        .background(GuideTheme.cardSurface, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(GuideTheme.border, lineWidth: 1)
        }
        .shadow(color: GuideTheme.primary.opacity(0.12), radius: 16, y: 8)
    }

    private var availabilityColor: Color {
        switch school.availability {
        case .fresh: GuideTheme.success
        case .stale: GuideTheme.warning
        case .unavailable, .suspended: GuideTheme.danger
        }
    }
}
