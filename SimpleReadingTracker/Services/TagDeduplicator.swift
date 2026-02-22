import Foundation
import SwiftData

enum TagDeduplicator {

    /// Finds an existing tag by name (case-insensitive), merges any duplicates,
    /// or creates a new one. Returns `nil` for empty/whitespace-only input.
    static func findOrCreate(named name: String, in context: ModelContext) -> Tag? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let lowered = trimmed.lowercased()
        let descriptor = FetchDescriptor<Tag>()
        let allTags = (try? context.fetch(descriptor)) ?? []
        let matches = allTags.filter { $0.name == lowered }

        if matches.count > 1 {
            return merge(duplicates: matches, in: context)
        } else if let existing = matches.first {
            return existing
        }

        let tag = Tag(name: trimmed)
        context.insert(tag)
        return tag
    }

    /// Scans all tags and merges any groups that share the same lowercased name.
    /// Call on app launch to clean up duplicates that arrived via CloudKit sync.
    static func deduplicateAll(in context: ModelContext) {
        let descriptor = FetchDescriptor<Tag>()
        guard let allTags = try? context.fetch(descriptor) else { return }

        var groups: [String: [Tag]] = [:]
        for tag in allTags {
            groups[tag.name, default: []].append(tag)
        }

        for (_, tags) in groups where tags.count > 1 {
            _ = merge(duplicates: tags, in: context)
        }

        try? context.save()
    }

    // MARK: - Private

    /// Keeps the first tag as the survivor. Moves books from duplicates,
    /// copies color if the survivor has none, then deletes duplicates.
    @discardableResult
    private static func merge(duplicates: [Tag], in context: ModelContext) -> Tag {
        let survivor = duplicates[0]
        let existingBookIDs = Set((survivor.books ?? []).map(\.persistentModelID))

        for duplicate in duplicates.dropFirst() {
            for book in duplicate.books ?? [] where !existingBookIDs.contains(book.persistentModelID) {
                survivor.books = (survivor.books ?? []) + [book]
            }

            if survivor.colorName == nil, let color = duplicate.colorName {
                survivor.colorName = color
            }

            // Remove the duplicate's book relationships before deletion
            duplicate.books?.removeAll()
            context.delete(duplicate)
        }

        return survivor
    }
}
