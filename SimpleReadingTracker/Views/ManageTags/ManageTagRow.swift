import SwiftUI

struct ManageTagRow: View {
    let tag: Tag
    let isEditing: Bool
    let editingName: Binding<String>
    let showColorPicker: Bool
    let onToggleColorPicker: () -> Void
    let onBeginEditing: () -> Void
    let onCommitRename: () -> Void
    let onCancelEditing: () -> Void
    let onSetColor: (TagColor?) -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                tagPreview

                Spacer()

                Text("\(tag.books.count)")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()

                actionButtons
            }

            if isEditing {
                renameField
            }

            if showColorPicker {
                TagColorPicker(selectedColor: tag.tagColor) { color in
                    onSetColor(color)
                }
                .padding(.leading, 4)
            }
        }
        .padding(.vertical, 4)
    }

    private var tagPreview: some View {
        Text(isEditing ? editingName.wrappedValue : tag.displayName)
            .font(.body)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(tag.resolvedColor.opacity(0.15))
            .foregroundStyle(.black)
            .clipShape(Capsule())
    }

    private var actionButtons: some View {
        HStack(spacing: 20) {
            Button(action: onToggleColorPicker) {
                Image(systemName: "paintpalette")
                    .foregroundStyle(showColorPicker ? .primary : .secondary)
                    .frame(minWidth: 36, minHeight: 36)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Change color")

            Button(action: onBeginEditing) {
                Image(systemName: "pencil")
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 36, minHeight: 36)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Rename")

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
                    .frame(minWidth: 36, minHeight: 36)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Delete")
        }
        .font(.title2)
    }

    private var renameField: some View {
        HStack(spacing: 12) {
            TextField("Tag name", text: editingName)
                .textFieldStyle(.roundedBorder)
                .onSubmit(onCommitRename)

            Button(action: onCommitRename) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .buttonStyle(.plain)

            Button(action: onCancelEditing) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .buttonStyle(.plain)
        }
        .font(.title2)
    }
}
