import SwiftUI

struct StatusChip: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(AppTypography.footnote)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(.white)
            .background(
                Capsule(style: .continuous)
                    .fill(color)
            )
    }
}
