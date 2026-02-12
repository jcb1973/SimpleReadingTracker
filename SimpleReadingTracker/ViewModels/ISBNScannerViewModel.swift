import Observation
import AVFoundation

@Observable
final class ISBNScannerViewModel {
    private let lookupService: any BookLookupService

    private(set) var scannedISBN: String?
    private(set) var lookupResult: BookLookupResult?
    private(set) var isLookingUp = false
    private(set) var error: String?
    var hasScanned = false

    var cameraPermissionGranted = false

    init(lookupService: any BookLookupService = RemoteBookLookupService()) {
        self.lookupService = lookupService
    }

    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermissionGranted = true
        case .notDetermined:
            Task {
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                cameraPermissionGranted = granted
            }
        default:
            cameraPermissionGranted = false
        }
    }

    func handleScannedCode(_ code: String) {
        guard !hasScanned else { return }
        hasScanned = true
        scannedISBN = code
        Task {
            await lookupISBN(code)
        }
    }

    func lookupISBN(_ isbn: String) async {
        isLookingUp = true
        error = nil
        do {
            lookupResult = try await lookupService.lookupISBN(isbn)
        } catch {
            self.error = error.localizedDescription
        }
        isLookingUp = false
    }

    func reset() {
        scannedISBN = nil
        lookupResult = nil
        error = nil
        hasScanned = false
        isLookingUp = false
    }
}
