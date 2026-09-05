import AudioToolbox
import UIKit

enum FeedbackService {
    private static var isScanSoundOn: Bool {
        UserDefaults.standard.bool(forKey: AppSettings.Key.isScanSoundOn)
    }

    static func playSuccess() {
        guard isScanSoundOn else { return }
        AudioServicesPlaySystemSound(1057)
    }

    static func playError() {
        guard isScanSoundOn else { return }
        AudioServicesPlaySystemSound(1051)
    }

    static func playErrorHaptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
