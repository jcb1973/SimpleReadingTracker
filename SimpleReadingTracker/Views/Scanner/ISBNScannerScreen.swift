import SwiftUI

struct ISBNScannerScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ISBNScannerViewModel()

    var onResult: (BookLookupResult) -> Void

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.cameraPermissionGranted {
                cameraView
            } else {
                permissionDeniedView
            }

            if viewModel.isLookingUp {
                ProgressView("Looking up book...")
            }

            if let error = viewModel.error {
                VStack(spacing: 8) {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                    Button("Try Again") {
                        viewModel.reset()
                    }
                    .buttonStyle(.bordered)
                }
            }

            if let result = viewModel.lookupResult {
                lookupResultView(result)
            }
        }
        .padding()
        .navigationTitle("Scan ISBN")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
        .task {
            viewModel.checkCameraPermission()
        }
    }

    private var cameraView: some View {
        CameraPreviewView { code in
            viewModel.handleScannedCode(code)
        }
        .frame(height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var permissionDeniedView: some View {
        EmptyStateView(
            systemImage: "camera.fill",
            title: "Camera Access Needed",
            message: "Please enable camera access in Settings to scan barcodes."
        )
    }

    private func lookupResultView(_ result: BookLookupResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(result.title)
                .font(.headline)
            if !result.authors.isEmpty {
                Text(result.authors.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Button("Use This Book") {
                onResult(result)
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
