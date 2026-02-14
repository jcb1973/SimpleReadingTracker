import Foundation
import Observation
import SwiftData
import UIKit
import VisionKit

@Observable
@MainActor
final class QuoteEditorViewModel {
    var text: String
    var pageNumberText: String
    let quote: Quote?
    var capturedImage: UIImage?
    var rawCapturedImage: UIImage?
    var showingCropView = false
    var isAnalyzing = false

    init(quote: Quote? = nil) {
        self.quote = quote
        self.text = quote?.text ?? ""
        self.pageNumberText = quote?.pageNumber.map(String.init) ?? ""
    }

    var canSave: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isLiveTextSupported: Bool {
        ImageAnalyzer.isSupported
    }

    func save(for book: Book, modelContext: ModelContext) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let pageNumber = Int(pageNumberText)

        if let quote {
            quote.text = trimmed
            quote.pageNumber = pageNumber
        } else {
            let newQuote = Quote(text: trimmed, pageNumber: pageNumber, book: book)
            modelContext.insert(newQuote)
        }

        try? modelContext.save()
    }

    func delete(modelContext: ModelContext) {
        guard let quote else { return }
        modelContext.delete(quote)
        try? modelContext.save()
    }

    func handleCapturedImage(_ data: Data) {
        guard let image = UIImage(data: data) else { return }
        rawCapturedImage = image
        showingCropView = true
    }

    func applyCroppedImage(_ image: UIImage) {
        capturedImage = image
        rawCapturedImage = nil
        showingCropView = false
    }

    func cancelCrop() {
        rawCapturedImage = nil
        showingCropView = false
    }
}
