import SwiftUI

struct AddCardView: View {
    var compact = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.title2)
                Text("Add")
                    .font(.caption)
            }
            .foregroundStyle(.tint)
            .frame(width: 80, height: compact ? 75 : 150)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.quaternary)
            )
        }
        .buttonStyle(.plain)
    }
}
