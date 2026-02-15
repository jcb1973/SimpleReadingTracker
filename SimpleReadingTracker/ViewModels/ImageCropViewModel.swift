import Observation
import UIKit

@Observable
@MainActor
final class ImageCropViewModel {
    let sourceImage: UIImage
    var normalizedCropRect: CGRect
    var croppedResult: UIImage?
    var isCropping = false

    private static let minimumDimension: CGFloat = 0.1

    init(sourceImage: UIImage) {
        self.sourceImage = sourceImage
        self.normalizedCropRect = CGRect(x: 0.1, y: 0.2, width: 0.8, height: 0.6)
    }

    func performCrop() async -> UIImage? {
        isCropping = true
        let image = sourceImage
        let cropRect = normalizedCropRect
        let result = await Task.detached {
            Self.cropImage(image, normalizedRect: cropRect)
        }.value
        isCropping = false
        croppedResult = result
        return result
    }

    func clampCropRect() {
        var rect = normalizedCropRect

        rect.size.width = max(rect.size.width, Self.minimumDimension)
        rect.size.height = max(rect.size.height, Self.minimumDimension)

        rect.origin.x = min(max(rect.origin.x, 0), 1 - rect.size.width)
        rect.origin.y = min(max(rect.origin.y, 0), 1 - rect.size.height)

        normalizedCropRect = rect
    }

    private nonisolated static func cropImage(_ image: UIImage, normalizedRect: CGRect) -> UIImage? {
        let normalized = normalizeOrientation(image)
        guard let cgImage = normalized.cgImage else { return nil }

        let pixelWidth = CGFloat(cgImage.width)
        let pixelHeight = CGFloat(cgImage.height)

        let cropPixelRect = CGRect(
            x: normalizedRect.origin.x * pixelWidth,
            y: normalizedRect.origin.y * pixelHeight,
            width: normalizedRect.width * pixelWidth,
            height: normalizedRect.height * pixelHeight
        ).integral

        guard let cropped = cgImage.cropping(to: cropPixelRect) else { return nil }
        return UIImage(cgImage: cropped, scale: normalized.scale, orientation: .up)
    }

    private nonisolated static func normalizeOrientation(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }

        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { _ in
            image.draw(at: .zero)
        }
    }
}
