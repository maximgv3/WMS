import Foundation
import AVFoundation

enum CameraAccessBlockReason: Identifiable {
    case notDetermined
    case denied

    var id: Self { self }
}


final class CameraPermissionService {
    func blockReason() -> CameraAccessBlockReason? {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return nil
        case .notDetermined:
            return .notDetermined
        case .denied, .restricted:
            return .denied
        @unknown default:
            return .denied
        }
    }

    func requestAccess() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }
}
