import SwiftUI

struct BookNotesSection: View {
    @Bindable var viewModel: BookDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)

            addNoteRow

            if viewModel.sortedNotes.isEmpty {
                Text("No notes yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.sortedNotes) { note in
                    noteRow(note)
                }
            }
        }
    }

    private var addNoteRow: some View {
        HStack {
            TextField("Add a note...", text: $viewModel.noteText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)
            Button {
                viewModel.addNote()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .imageScale(.large)
            }
            .disabled(viewModel.noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private func noteRow(_ note: Note) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.content)
                .font(.body)
            Text(note.createdAt, style: .date)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .contextMenu {
            Button(role: .destructive) {
                viewModel.deleteNote(note)
            } label: {
                Label("Delete Note", systemImage: "trash")
            }
        }
    }
}
