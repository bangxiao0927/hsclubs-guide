import SwiftUI

struct SchoolCard: View {
    let school: School

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor.opacity(0.14))
                    Text(school.shortName.prefix(3))
                        .font(.caption.bold())
                        .foregroundStyle(Color.accentColor)
                }
                .frame(width: 48, height: 48)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(school.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(school.location.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.tertiary)
            }

            HStack {
                Label("Verified", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                Spacer()
                if let clubCount = school.clubCount {
                    Text("\(clubCount) clubs")
                        .foregroundStyle(.secondary)
                }
            }
            .font(.caption.weight(.semibold))

            Text(school.availability.label)
                .font(.caption)
                .foregroundStyle(availabilityColor)
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        }
    }

    private var availabilityColor: Color {
        switch school.availability {
        case .fresh: .green
        case .stale: .orange
        case .unavailable, .suspended: .red
        }
    }
}
