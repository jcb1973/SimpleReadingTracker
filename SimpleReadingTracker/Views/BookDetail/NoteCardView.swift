import SwiftUI

struct NoteCardView: View {
    let note: Note

    var body: some View {
        TextCard(accessibilityLabel: "Note: \(note.content)") {
            VStack(alignment: .leading, spacing: 8) {
                Text(note.content)
                    .font(.subheadline)
                    .lineLimit(6)
                    .multilineTextAlignment(.leading)

                Spacer()

                Text(note.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
