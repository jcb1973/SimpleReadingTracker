import SwiftData
import SwiftUI

struct LibraryTagBar: View {
    let tags: [Tag]
    let selectedTagIDs: Set<PersistentIdentifier>
    let onToggle: (Tag) -> Void

    private let collapsedLimit = 10
    @State private var isExpanded = false

    private var visibleTags: [Tag] {
        if isExpanded || tags.count <= collapsedLimit {
            return tags
        }
        return Array(tags.prefix(collapsedLimit))
    }

    var body: some View {
        guard !tags.isEmpty else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(alignment: .leading, spacing: 8) {
                Text("Filter by tags")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                FlowLayout(spacing: 8) {
                    ForEach(visibleTags) { tag in
                        TagFilterChip(
                            name: tag.displayName,
                            count: tag.books.count,
                            isSelected: selectedTagIDs.contains(tag.persistentModelID)
                        ) {
                            onToggle(tag)
                        }
                    }
                }

                if tags.count > collapsedLimit {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Text(isExpanded ? "Show less" : "Show all")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        )
    }
}

private struct TagFilterChip: View {
    let name: String
    let count: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(name)
                Text("\(count)")
                    .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .font(.subheadline)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.tertiarySystemFill))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
