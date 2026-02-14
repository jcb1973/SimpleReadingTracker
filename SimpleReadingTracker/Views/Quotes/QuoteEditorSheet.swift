import SwiftUI
import SwiftData
import VisionKit

struct QuoteEditorSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: QuoteEditorViewModel
    @State private var showingCamera = false
    @State private var showingDeleteConfirmation = false

    let book: Book

    init(book: Book, quote: Quote? = nil) {
        self.book = book
        self._viewModel = State(initialValue: QuoteEditorViewModel(quote: quote))
    }

    private var isEditing: Bool {
        viewModel.quote != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextEditor(text: $viewModel.text)
                        .frame(minHeight: isEditing ? 400 : 50)
                } header: {
                    Text("Quote Text")
                } footer: {
                    if viewModel.isLiveTextSupported {
                        Text("Use the camera to photograph a page and select text.")
                    }
                }

                if let image = viewModel.capturedImage {
                    Section("Captured Page") {
                        QuoteLiveTextView(image: image) { recognizedText in
                            if !recognizedText.isEmpty {
                                viewModel.text = recognizedText
                            }
                        }
                        .frame(height: 300)
                    }
                }

                Section {
                    if viewModel.isLiveTextSupported && CameraImagePicker.isAvailable {
                        Button {
                            showingCamera = true
                        } label: {
                            Label("Photograph Page", systemImage: "camera")
                        }
                    }
                }

                Section("Page Number") {
                    TextField("Optional", text: $viewModel.pageNumberText)
                        .keyboardType(.numberPad)
                }

                if isEditing, let quote = viewModel.quote {
                    Section {
                        LabeledContent("Created") {
                            Text(quote.createdAt, style: .date)
                        }
                    }

                    Section {
                        Button("Delete Quote", role: .destructive) {
                            showingDeleteConfirmation = true
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Quote" : "New Quote")
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
            .sheet(isPresented: $showingCamera) {
                CameraImagePicker { data in
                    viewModel.handleCapturedImage(data)
                }
            }
            .fullScreenCover(isPresented: $viewModel.showingCropView) {
                if let rawImage = viewModel.rawCapturedImage {
                    ImageCropView(
                        sourceImage: rawImage,
                        onCropConfirmed: { cropped in
                            viewModel.applyCroppedImage(cropped)
                        },
                        onCancel: {
                            viewModel.cancelCrop()
                        }
                    )
                }
            }
            .alert("Delete Quote", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    viewModel.delete(modelContext: modelContext)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this quote?")
            }
        }
    }
}
