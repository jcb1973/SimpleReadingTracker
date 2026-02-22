import SwiftUI
import SwiftData

struct ManageTagsScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ManageTagsViewModel?
    @State private var tagToDelete: Tag?
    @State private var expandedColorTagID: PersistentIdentifier?

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    tagList(vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Manage Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Delete Tag", isPresented: Binding(
                get: { tagToDelete != nil },
                set: { if !$0 { tagToDelete = nil } }
            )) {
                Button("Delete", role: .destructive) {
                    if let tag = tagToDelete {
                        viewModel?.deleteTag(tag)
                        expandedColorTagID = nil
                    }
                    tagToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    tagToDelete = nil
                }
            } message: {
                if let tag = tagToDelete {
                    Text("Delete \"\(tag.displayName)\"? It will be removed from \((tag.books ?? []).count) book\((tag.books ?? []).count == 1 ? "" : "s").")
                }
            }
        }
        .task {
            let vm = ManageTagsViewModel(modelContext: modelContext)
            vm.fetchTags()
            viewModel = vm
        }
    }

    private func tagList(_ vm: ManageTagsViewModel) -> some View {
        List {
            createSection(vm)
            tagsSection(vm)
        }
        .overlay {
            if let errorMessage = vm.error {
                errorBanner(errorMessage, vm: vm)
            }
        }
    }

    private func createSection(_ vm: ManageTagsViewModel) -> some View {
        Section("Create Tag") {
            HStack(spacing: 8) {
                TextField("New tag name...", text: Binding(
                    get: { vm.newTagName },
                    set: { vm.newTagName = $0 }
                ))
                .textFieldStyle(.roundedBorder)
                .onSubmit { vm.createTag() }

                Button {
                    vm.createTag()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                }
                .disabled(vm.newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func tagsSection(_ vm: ManageTagsViewModel) -> some View {
        Section("Tags (\(vm.tags.count))") {
            if vm.tags.isEmpty {
                Text("No tags yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(vm.tags) { tag in
                    ManageTagRow(
                        tag: tag,
                        isEditing: vm.editingTagID == tag.persistentModelID,
                        editingName: Binding(
                            get: { vm.editingName },
                            set: { vm.editingName = $0 }
                        ),
                        showColorPicker: expandedColorTagID == tag.persistentModelID,
                        onToggleColorPicker: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if expandedColorTagID == tag.persistentModelID {
                                    expandedColorTagID = nil
                                } else {
                                    expandedColorTagID = tag.persistentModelID
                                }
                            }
                        },
                        onBeginEditing: { vm.beginEditing(tag) },
                        onCommitRename: { vm.commitRename() },
                        onCancelEditing: { vm.cancelEditing() },
                        onSetColor: { vm.setColor($0, for: tag) },
                        onDelete: { tagToDelete = tag }
                    )
                }
            }
        }
    }

    private func errorBanner(_ message: String, vm: ManageTagsViewModel) -> some View {
        VStack {
            Spacer()
            Text(message)
                .font(.footnote)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.red.opacity(0.9))
                .clipShape(Capsule())
                .padding(.bottom, 16)
                .onTapGesture { vm.error = nil }
        }
    }
}
