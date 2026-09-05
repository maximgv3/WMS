import SwiftUI

enum AppSettings {
    enum Key {
        static let colorScheme = "colorScheme"
        static let isScanSoundOn = "isScanSoundOn"
        static let isScreenAlwaysOn = "isScreenAlwaysOn"
    }

    // Defaults for readers outside SwiftUI, where @AppStorage cannot supply them.
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            Key.isScanSoundOn: true,
            Key.isScreenAlwaysOn: true
        ])
    }
}

enum AppColorScheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "Системная"
        case .light: "Светлая"
        case .dark: "Тёмная"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: .unspecified
        case .light: .light
        case .dark: .dark
        }
    }
}
