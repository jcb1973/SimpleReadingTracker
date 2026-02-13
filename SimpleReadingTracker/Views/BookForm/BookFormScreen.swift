import SwiftData
import SwiftUI

struct BookFormScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: BookFormViewModel?
    @State private var showingScanner = false

    let mode: BookFormMode

    var body: some View {
        Group {
            if let viewModel {
                formContent(viewModel)
            } else {
                ProgressView()
            }
        }
        .task {
            viewModel = BookFormViewModel(mode: mode, modelContext: modelContext)
        }
    }

    private func formContent(_ vm: BookFormViewModel) -> some View {
        Form {
            isbnSection(vm)
            titleSection(vm)
            AuthorEntryView(authorNames: Binding(
                get: { vm.authorNames },
                set: { vm.authorNames = $0 }
            ), onAddField: vm.addAuthorField, onRemoveField: vm.removeAuthorField)
            detailsSection(vm)
            statusSection(vm)
        }
        .navigationTitle(vm.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    vm.save()
                    dismiss()
                }
                .disabled(!vm.isValid)
            }
        }
        .sheet(isPresented: $showingScanner) {
            NavigationStack {
                ISBNScannerScreen { result in
                    vm.title = result.title
                    if !result.authors.isEmpty {
                        vm.authorNames = result.authors
                    }
                    vm.isbn = result.isbn ?? ""
                    if let url = result.coverImageURL {
                        vm.coverImageURL = url
                        Task { await vm.downloadCoverImage(from: url) }
                    }
                    if let pub = result.publisher { vm.publisher = pub }
                    if let date = result.publishedDate { vm.publishedDate = date }
                    if let desc = result.description { vm.bookDescription = desc }
                    if let pages = result.pageCount { vm.pageCountString = String(pages) }
                    showingScanner = false
                }
            }
        }
    }

    private func isbnSection(_ vm: BookFormViewModel) -> some View {
        Section("Scan ISBN code for automatic entry") {
            HStack {
                TextField("ISBN", text: Binding(
                    get: { vm.isbn },
                    set: { vm.isbn = $0 }
                ))
                .keyboardType(.numberPad)

                if vm.isLookingUp {
                    ProgressView()
                } else {
                    Button("Lookup") {
                        Task { await vm.lookupISBN() }
                    }
                    .disabled(vm.isbn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }

            Button {
                showingScanner = true
            } label: {
                Label("Scan Barcode", systemImage: "barcode.viewfinder")
            }

            if let lookupError = vm.lookupError {
                Text(lookupError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private func titleSection(_ vm: BookFormViewModel) -> some View {
        Section("Title") {
            TextField("Book Title", text: Binding(
                get: { vm.title },
                set: { vm.title = $0 }
            ))
        }
    }

    private func detailsSection(_ vm: BookFormViewModel) -> some View {
        Section("Details") {
            TextField("Publisher", text: Binding(
                get: { vm.publisher },
                set: { vm.publisher = $0 }
            ))
            TextField("Published Date", text: Binding(
                get: { vm.publishedDate },
                set: { vm.publishedDate = $0 }
            ))
            TextField("Page Count", text: Binding(
                get: { vm.pageCountString },
                set: { vm.pageCountString = $0 }
            ))
            .keyboardType(.numberPad)
            TextField("Cover Image URL", text: Binding(
                get: { vm.coverImageURL },
                set: { vm.coverImageURL = $0 }
            ))
            .keyboardType(.URL)
            .textInputAutocapitalization(.never)
            TextField("Description", text: Binding(
                get: { vm.bookDescription },
                set: { vm.bookDescription = $0 }
            ), axis: .vertical)
            .lineLimit(3...6)
        }
    }

    private func statusSection(_ vm: BookFormViewModel) -> some View {
        Section("Status & Rating") {
            Picker("Status", selection: Binding(
                get: { vm.status },
                set: { vm.status = $0 }
            )) {
                ForEach(ReadingStatus.allCases) { status in
                    Text(status.displayName).tag(status)
                }
            }

            StarRatingView(rating: Binding(
                get: { vm.rating },
                set: { vm.rating = $0 }
            ))
        }
    }
}
