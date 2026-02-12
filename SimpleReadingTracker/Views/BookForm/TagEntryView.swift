import SwiftUI

struct TagEntryView: View {
    @Binding var tagNames: [String]
    var onAddField: () -> Void
    var onRemoveField: (Int) -> Void

    var body: some View {
        Section("Tags") {
            ForEach(tagNames.indices, id: \.self) { index in
                HStack {
                    TextField("Tag name", text: $tagNames[index])
                    if tagNames.count > 1 {
                        Button {
                            onRemoveField(index)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            Button {
                onAddField()
            } label: {
                Label("Add Tag", systemImage: "plus.circle")
            }
        }
    }
}
