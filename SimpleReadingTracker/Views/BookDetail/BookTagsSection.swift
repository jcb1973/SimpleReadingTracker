import SwiftUI

struct BookTagsSection: View {
    let book: Book
    let onAdd: (String) -> Void
    let onRemove: (Tag) -> Void

    @State private var newTagName = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.headline)

            if !book.tags.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(book.tags) { tag in
                        RemovableTagChip(name: tag.displayName) {
                            onRemove(tag)
                        }
                    }
                }
            }

            HStack(spacing: 8) {
                TextField("Add tag...", text: $newTagName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(addTag)

                Button(action: addTag) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func addTag() {
        let trimmed = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onAdd(trimmed)
        newTagName = ""
    }
}

private struct RemovableTagChip: View {
    let name: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(name)
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.tint.opacity(0.15))
        .foregroundStyle(.tint)
        .clipShape(Capsule())
    }
}
