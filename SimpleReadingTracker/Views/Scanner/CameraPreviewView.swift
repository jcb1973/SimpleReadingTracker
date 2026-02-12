import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    var onCodeScanned: (String) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = CameraContainerView()
        let coordinator = context.coordinator

        Task.detached {
            let session = AVCaptureSession()

            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device) else {
                return
            }

            session.beginConfiguration()
            if session.canAddInput(input) {
                session.addInput(input)
            }

            let output = AVCaptureMetadataOutput()
            if session.canAddOutput(output) {
                session.addOutput(output)
                output.setMetadataObjectsDelegate(coordinator, queue: .main)
                output.metadataObjectTypes = [.ean13, .ean8]
            }
            session.commitConfiguration()

            await MainActor.run {
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.frame = view.bounds
                view.layer.addSublayer(previewLayer)
                coordinator.previewLayer = previewLayer
                view.previewLayer = previewLayer
            }

            coordinator.session = session
            session.startRunning()
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let container = uiView as? CameraContainerView {
            container.previewLayer?.frame = uiView.bounds
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onCodeScanned: onCodeScanned)
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        let session = coordinator.session
        coordinator.session = nil
        coordinator.previewLayer = nil
        Task.detached {
            session?.stopRunning()
        }
    }

    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var session: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer?
        let onCodeScanned: (String) -> Void

        init(onCodeScanned: @escaping (String) -> Void) {
            self.onCodeScanned = onCodeScanned
        }

        nonisolated func metadataOutput(
            _ output: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from connection: AVCaptureConnection
        ) {
            guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let code = object.stringValue else { return }
            MainActor.assumeIsolated {
                onCodeScanned(code)
            }
        }
    }
}

private final class CameraContainerView: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}
