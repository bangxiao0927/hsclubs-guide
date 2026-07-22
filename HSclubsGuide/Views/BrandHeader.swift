import SwiftUI

/// The persistent "HS Clubs" brand row shown at the top of primary screens,
/// mirroring the header on hsclubs.net. Purely decorative branding; it holds
/// no navigation, authentication, or account actions.
struct BrandHeader: View {
    /// Optional short caption shown under the wordmark (e.g. a screen context).
    var caption: String?

    init(caption: String? = nil) {
        self.caption = caption
    }

    var body: some View {
        HStack(spacing: 12) {
            logoMark
            VStack(alignment: .leading, spacing: 1) {
                Text("HS Clubs")
                    .font(.headline.bold())
                    .foregroundStyle(GuideTheme.textPrimary)
                if let caption, !caption.isEmpty {
                    Text(caption)
                        .font(.caption)
                        .foregroundStyle(GuideTheme.textMuted)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("HS Clubs")
    }

    private var logoMark: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(GuideTheme.primarySoft)
            Text("HS")
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(GuideTheme.primary)
        }
        .frame(width: 40, height: 40)
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(GuideTheme.border, lineWidth: 1)
        }
        .accessibilityHidden(true)
    }
}
