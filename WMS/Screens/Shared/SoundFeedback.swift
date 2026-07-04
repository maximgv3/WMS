import AudioToolbox

enum SoundFeedback {
    static func playSuccess() {
        AudioServicesPlaySystemSound(1057)
    }

    static func playError() {
        AudioServicesPlaySystemSound(1051)
    }
}
