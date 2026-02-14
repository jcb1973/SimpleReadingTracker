import SwiftData
import SwiftUI

struct LibraryTagBar: View {
    let tags: [Tag]
    let selectedTagIDs: Set<PersistentIdentifier>
    let tagFilterMode: TagFilterMode
    let onToggle: (Tag) -> Void
    let onToggleMode: () -> Void

    private let collapsedLimit = 10
    @State private var isExpanded = false

    private var visibleTags: [Tag] {
        if isExpanded || tags.count <= collapsedLimit {
            return tags
        }
        return Array(tags.prefix(collapsedLimit))
    }

    private var selectedCount: Int {
        selectedTagIDs.count
    }

    var body: some View {
        guard !tags.isEmpty else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Filter by tags")
                        .font(.subheadline)

                    Spacer()

                    if selectedCount >= 2 {
                        TagFilterModeToggle(
                            mode: tagFilterMode,
                            onToggle: onToggleMode
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                    }
                }

                FlowLayout(spacing: 8) {
                    ForEach(visibleTags) { tag in
                        TagFilterChip(
                            name: tag.displayName,
                            count: tag.books.count,
                            isSelected: selectedTagIDs.contains(tag.persistentModelID),
                            color: tag.resolvedColor
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
            .padding(.vertical, 8)
            .animation(.easeInOut(duration: 0.2), value: selectedCount >= 2)
        )
    }
}

private struct TagFilterModeToggle: View {
    let mode: TagFilterMode
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 4) {
                Text("Match")
                    .foregroundStyle(.secondary)
                Text(mode == .and ? "All" : "Any")
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(.tertiarySystemFill))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Tag filter mode: \(mode == .and ? "all" : "any")")
        .accessibilityHint("Double tap to switch to \(mode == .and ? "any" : "all")")
    }
}

private struct TagFilterChip: View {
    let name: String
    let count: Int
    let isSelected: Bool
    var color: Color = .accentColor
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(name)
                Text("\(count)")
                    .foregroundStyle(.black)
            }
            .font(.subheadline)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? color : color.opacity(0.12))
            .foregroundStyle(.black)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
