import SwiftUI

struct TagChipView: View {
    let name: String

    var body: some View {
        Text(name)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.tint.opacity(0.15))
            .foregroundStyle(.tint)
            .clipShape(Capsule())
    }
}
