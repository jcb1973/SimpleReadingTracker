import SwiftUI

struct AuthorEntryView: View {
    @Binding var authorNames: [String]
    var onAddField: () -> Void
    var onRemoveField: (Int) -> Void

    var body: some View {
        Section("Authors") {
            ForEach(authorNames.indices, id: \.self) { index in
                HStack {
                    TextField("Author name", text: $authorNames[index])
                    if authorNames.count > 1 {
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
                Label("Add Author", systemImage: "plus.circle")
            }
        }
    }
}
