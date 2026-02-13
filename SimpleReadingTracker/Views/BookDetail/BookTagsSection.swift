import SwiftData
import SwiftUI

struct BookTagsSection: View {
    let book: Book
    let onAdd: (String) -> Void
    let onRemove: (Tag) -> Void

    @Query(sort: \Tag.name) private var allTags: [Tag]
    @State private var newTagName = ""
    @State private var isExpanded = false

    private var filteredTags: [Tag] {
        let bookTagIDs = Set(book.tags.map(\.persistentModelID))
        return allTags
            .filter { !bookTagIDs.contains($0.persistentModelID) }
            .sorted { $0.books.count > $1.books.count }
    }

    private var suggestedTags: [Tag] {
        if isExpanded {
            return filteredTags
        }
        return Array(filteredTags.prefix(5))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.headline)

            if !book.tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(book.tags) { tag in
                        RemovableTagChip(name: tag.displayName, color: tag.resolvedColor) {
                            onRemove(tag)
                        }
                    }
                }
            }

            if !filteredTags.isEmpty {
                suggestionsSection
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

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(isExpanded ? "All Library Tags" : "Suggestions")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if filteredTags.count > 5 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Text(isExpanded ? "Show Less" : "Show More")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }

            FlowLayout(spacing: 8) {
                ForEach(suggestedTags) { tag in
                    SuggestedTagChip(name: tag.displayName, color: tag.resolvedColor) {
                        onAdd(tag.displayName)
                    }
                }
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
    var color: Color = .accentColor
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
        .font(.subheadline)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.15))
        .foregroundStyle(color)
        .clipShape(Capsule())
    }
}

private struct SuggestedTagChip: View {
    let name: String
    var color: Color = .accentColor
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(name)
                Image(systemName: "plus")
                    .font(.caption2)
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.08))
            .foregroundStyle(color)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(color.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            }
        }
        .buttonStyle(.plain)
    }
}
