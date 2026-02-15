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
                        .font(.headline)

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
            HStack(spacing: 8) {
                Text("Match")
                Text(mode == .and ? "All" : "Any")
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .font(.callout)
            .padding(.horizontal, 13)
            .padding(.vertical, 7)
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
    let isSelected: Bool
    var color: Color = .accentColor
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(name)
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
