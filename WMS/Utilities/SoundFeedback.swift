import AudioToolbox
import UIKit

enum SoundFeedback {
    static func playSuccess() {
        AudioServicesPlaySystemSound(1057)
    }

    static func playError() {
        AudioServicesPlaySystemSound(1051)
    }

    static func playErrorHaptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
