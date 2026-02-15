import SwiftUI

struct NoteCardView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.content)
                .font(.subheadline)
                .lineLimit(5)
                .multilineTextAlignment(.leading)

            Spacer()

            Text(note.createdAt, style: .date)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(width: 200, height: 150, alignment: .topLeading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Note: \(note.content)")
    }
}
