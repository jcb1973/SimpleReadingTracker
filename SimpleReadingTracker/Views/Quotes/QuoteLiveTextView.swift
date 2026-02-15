import SwiftUI
import VisionKit

@MainActor
struct QuoteLiveTextView: UIViewRepresentable {
    let image: UIImage
    let onTextRecognized: (String) -> Void

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true

        let interaction = ImageAnalysisInteraction()
        interaction.preferredInteractionTypes = .textSelection
        imageView.addInteraction(interaction)

        context.coordinator.interaction = interaction
        context.coordinator.analyzeImage(image)

        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {}

    static func dismantleUIView(_ uiView: UIImageView, coordinator: Coordinator) {
        coordinator.cancelAnalysis()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onTextRecognized: onTextRecognized)
    }

    @MainActor
    final class Coordinator: NSObject {
        let onTextRecognized: (String) -> Void
        var interaction: ImageAnalysisInteraction?
        private var analysisTask: Task<Void, Never>?

        init(onTextRecognized: @escaping (String) -> Void) {
            self.onTextRecognized = onTextRecognized
        }

        func analyzeImage(_ image: UIImage) {
            guard ImageAnalyzer.isSupported else { return }

            analysisTask?.cancel()
            analysisTask = Task {
                let analyzer = ImageAnalyzer()
                let configuration = ImageAnalyzer.Configuration([.text])
                do {
                    let analysis = try await analyzer.analyze(image, configuration: configuration)
                    guard !Task.isCancelled else { return }
                    interaction?.analysis = analysis
                    if !analysis.transcript.isEmpty {
                        onTextRecognized(analysis.transcript)
                    }
                } catch {
                    // Analysis failed — user can enter text manually
                }
            }
        }

        func cancelAnalysis() {
            analysisTask?.cancel()
            analysisTask = nil
        }
    }
}
