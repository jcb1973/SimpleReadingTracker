import SwiftUI
import SwiftData

struct NoteEditorSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: NoteEditorViewModel
    @State private var showingDeleteConfirmation = false

    let book: Book

    init(book: Book, note: Note? = nil) {
        self.book = book
        self._viewModel = State(initialValue: NoteEditorViewModel(note: note))
    }

    private var isEditing: Bool {
        viewModel.note != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextEditor(text: $viewModel.content)
                        .frame(minHeight: 200)
                }

                if isEditing, let note = viewModel.note {
                    Section {
                        LabeledContent("Created") {
                            Text(note.createdAt, style: .date)
                        }
                    }

                    Section {
                        Button("Delete Note", role: .destructive) {
                            showingDeleteConfirmation = true
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Note" : "New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save(for: book, modelContext: modelContext)
                        dismiss()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .alert("Delete Note", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    viewModel.delete(modelContext: modelContext)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this note?")
            }
        }
    }
}
