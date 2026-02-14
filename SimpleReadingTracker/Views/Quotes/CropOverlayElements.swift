import SwiftUI

// MARK: - Coordinate Helpers

func calculateImageRect(imageSize: CGSize, in containerSize: CGSize) -> CGRect {
    guard imageSize.width > 0, imageSize.height > 0 else { return .zero }

    let imageAspect = imageSize.width / imageSize.height
    let containerAspect = containerSize.width / containerSize.height

    let displaySize: CGSize
    if imageAspect > containerAspect {
        displaySize = CGSize(width: containerSize.width, height: containerSize.width / imageAspect)
    } else {
        displaySize = CGSize(width: containerSize.height * imageAspect, height: containerSize.height)
    }

    let origin = CGPoint(
        x: (containerSize.width - displaySize.width) / 2,
        y: (containerSize.height - displaySize.height) / 2
    )
    return CGRect(origin: origin, size: displaySize)
}

func screenRect(from normalized: CGRect, in imageRect: CGRect) -> CGRect {
    CGRect(
        x: imageRect.origin.x + normalized.origin.x * imageRect.width,
        y: imageRect.origin.y + normalized.origin.y * imageRect.height,
        width: normalized.width * imageRect.width,
        height: normalized.height * imageRect.height
    )
}

func normalizedRect(from screen: CGRect, in imageRect: CGRect) -> CGRect {
    guard imageRect.width > 0, imageRect.height > 0 else { return .zero }
    return CGRect(
        x: (screen.origin.x - imageRect.origin.x) / imageRect.width,
        y: (screen.origin.y - imageRect.origin.y) / imageRect.height,
        width: screen.width / imageRect.width,
        height: screen.height / imageRect.height
    )
}

// MARK: - Dimming Overlay

struct CropDimmingOverlay: View {
    let cropScreenRect: CGRect

    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.addRect(CGRect(origin: .zero, size: geo.size))
                path.addRect(cropScreenRect)
            }
            .fill(Color.black.opacity(0.5), style: FillStyle(eoFill: true))
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Crop Rect Overlay

struct CropRectOverlay: View {
    @Bindable var viewModel: ImageCropViewModel
    let imageRect: CGRect

    private let handleSize: CGFloat = 24
    private let minimumDimension: CGFloat = 0.1

    var body: some View {
        let cropScreen = screenRect(from: viewModel.normalizedCropRect, in: imageRect)

        ZStack {
            // Border
            Rectangle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: cropScreen.width, height: cropScreen.height)
                .position(x: cropScreen.midX, y: cropScreen.midY)

            // Move gesture on the rectangle body
            Rectangle()
                .fill(Color.white.opacity(0.001))
                .frame(width: max(cropScreen.width - handleSize * 2, 0),
                       height: max(cropScreen.height - handleSize * 2, 0))
                .position(x: cropScreen.midX, y: cropScreen.midY)
                .gesture(moveGesture)

            // Corner handles
            cornerHandle(at: .topLeft, cropScreen: cropScreen)
            cornerHandle(at: .topRight, cropScreen: cropScreen)
            cornerHandle(at: .bottomLeft, cropScreen: cropScreen)
            cornerHandle(at: .bottomRight, cropScreen: cropScreen)
        }
    }

    // MARK: - Corner Handle

    private func cornerHandle(at corner: Corner, cropScreen: CGRect) -> some View {
        let position = corner.position(in: cropScreen)

        return Circle()
            .fill(Color.white)
            .frame(width: handleSize, height: handleSize)
            .shadow(radius: 2)
            .position(position)
            .gesture(cornerDragGesture(for: corner))
    }

    // MARK: - Corner Enum

    private enum Corner {
        case topLeft, topRight, bottomLeft, bottomRight

        func position(in rect: CGRect) -> CGPoint {
            switch self {
            case .topLeft: CGPoint(x: rect.minX, y: rect.minY)
            case .topRight: CGPoint(x: rect.maxX, y: rect.minY)
            case .bottomLeft: CGPoint(x: rect.minX, y: rect.maxY)
            case .bottomRight: CGPoint(x: rect.maxX, y: rect.maxY)
            }
        }
    }

    // MARK: - Gestures

    @State private var dragStartRect: CGRect?

    private var moveGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if dragStartRect == nil {
                    dragStartRect = viewModel.normalizedCropRect
                }
                guard let startRect = dragStartRect else { return }

                let dx = value.translation.width / imageRect.width
                let dy = value.translation.height / imageRect.height

                var newRect = startRect
                newRect.origin.x = startRect.origin.x + dx
                newRect.origin.y = startRect.origin.y + dy

                newRect.origin.x = min(max(newRect.origin.x, 0), 1 - newRect.width)
                newRect.origin.y = min(max(newRect.origin.y, 0), 1 - newRect.height)

                viewModel.normalizedCropRect = newRect
            }
            .onEnded { _ in
                dragStartRect = nil
            }
    }

    private func cornerDragGesture(for corner: Corner) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if dragStartRect == nil {
                    dragStartRect = viewModel.normalizedCropRect
                }
                guard let startRect = dragStartRect else { return }

                let dx = value.translation.width / imageRect.width
                let dy = value.translation.height / imageRect.height

                var rect = startRect
                switch corner {
                case .topLeft:
                    rect.origin.x = startRect.origin.x + dx
                    rect.origin.y = startRect.origin.y + dy
                    rect.size.width = startRect.width - dx
                    rect.size.height = startRect.height - dy
                case .topRight:
                    rect.origin.y = startRect.origin.y + dy
                    rect.size.width = startRect.width + dx
                    rect.size.height = startRect.height - dy
                case .bottomLeft:
                    rect.origin.x = startRect.origin.x + dx
                    rect.size.width = startRect.width - dx
                    rect.size.height = startRect.height + dy
                case .bottomRight:
                    rect.size.width = startRect.width + dx
                    rect.size.height = startRect.height + dy
                }

                // Enforce minimum size
                if rect.width < minimumDimension {
                    switch corner {
                    case .topLeft, .bottomLeft:
                        rect.origin.x = startRect.maxX - minimumDimension
                    default: break
                    }
                    rect.size.width = minimumDimension
                }
                if rect.height < minimumDimension {
                    switch corner {
                    case .topLeft, .topRight:
                        rect.origin.y = startRect.maxY - minimumDimension
                    default: break
                    }
                    rect.size.height = minimumDimension
                }

                // Clamp to image bounds
                rect.origin.x = max(rect.origin.x, 0)
                rect.origin.y = max(rect.origin.y, 0)
                if rect.maxX > 1 { rect.size.width = 1 - rect.origin.x }
                if rect.maxY > 1 { rect.size.height = 1 - rect.origin.y }

                viewModel.normalizedCropRect = rect
            }
            .onEnded { _ in
                dragStartRect = nil
                viewModel.clampCropRect()
            }
    }
}
