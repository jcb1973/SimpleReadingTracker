import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class ManageTagsViewModel {
    private let modelContext: ModelContext

    private(set) var tags: [Tag] = []
    var error: String?

    var editingTagID: PersistentIdentifier?
    var editingName = ""
    var newTagName = ""

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Fetch

    func fetchTags() {
        do {
            let descriptor = FetchDescriptor<Tag>(sortBy: [SortDescriptor(\.name)])
            tags = try modelContext.fetch(descriptor)
            error = nil
        } catch {
            self.error = PersistenceError.fetchFailed(underlying: error).localizedDescription
        }
    }

    // MARK: - Create

    func createTag() {
        let trimmed = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let lowered = trimmed.lowercased()
        guard !tags.contains(where: { $0.name == lowered }) else {
            error = "A tag named \"\(trimmed)\" already exists."
            return
        }

        let tag = Tag(name: trimmed)
        modelContext.insert(tag)
        save()
        newTagName = ""
        fetchTags()
    }

    // MARK: - Rename

    func beginEditing(_ tag: Tag) {
        editingTagID = tag.persistentModelID
        editingName = tag.displayName
    }

    func commitRename() {
        guard let tagID = editingTagID,
              let tag = tags.first(where: { $0.persistentModelID == tagID }) else {
            cancelEditing()
            return
        }

        let trimmed = editingName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            cancelEditing()
            return
        }

        let lowered = trimmed.lowercased()
        if tags.contains(where: { $0.persistentModelID != tagID && $0.name == lowered }) {
            error = "A tag named \"\(trimmed)\" already exists."
            return
        }

        tag.name = lowered
        tag.displayName = trimmed
        save()
        cancelEditing()
        fetchTags()
    }

    func cancelEditing() {
        editingTagID = nil
        editingName = ""
    }

    // MARK: - Color

    func setColor(_ color: TagColor?, for tag: Tag) {
        tag.tagColor = color
        save()
    }

    // MARK: - Delete

    func deleteTag(_ tag: Tag) {
        for book in tag.books {
            book.tags.removeAll { $0.persistentModelID == tag.persistentModelID }
        }
        modelContext.delete(tag)
        save()
        fetchTags()
    }

    // MARK: - Private

    private func save() {
        do {
            try modelContext.save()
            error = nil
        } catch {
            self.error = PersistenceError.saveFailed(underlying: error).localizedDescription
        }
    }
}
