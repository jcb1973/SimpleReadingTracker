import SwiftUI

struct ImageCropView: View {
    @State private var viewModel: ImageCropViewModel
    let onCropConfirmed: (UIImage) -> Void
    let onCancel: () -> Void

    init(sourceImage: UIImage, onCropConfirmed: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
        self._viewModel = State(initialValue: ImageCropViewModel(sourceImage: sourceImage))
        self.onCropConfirmed = onCropConfirmed
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let imgRect = calculateImageRect(imageSize: viewModel.sourceImage.size, in: geo.size)
                let cropScreen = screenRect(from: viewModel.normalizedCropRect, in: imgRect)

                ZStack {
                    Color.black.ignoresSafeArea()
                    Image(uiImage: viewModel.sourceImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    CropDimmingOverlay(cropScreenRect: cropScreen)
                    CropRectOverlay(viewModel: viewModel, imageRect: imgRect)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crop") {
                        Task {
                            guard let cropped = await viewModel.performCrop() else { return }
                            onCropConfirmed(cropped)
                        }
                    }
                    .disabled(viewModel.isCropping)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
