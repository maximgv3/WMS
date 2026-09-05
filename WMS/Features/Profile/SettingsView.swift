import SwiftUI

struct SettingsView: View {
    // MARK: - State

    @AppStorage(AppSettings.Key.colorScheme) private var appColorScheme =
        AppColorScheme.system
    @AppStorage(AppSettings.Key.isScanSoundOn) private var isScanSoundOn = true
    @AppStorage(AppSettings.Key.isScreenAlwaysOn) private var isScreenAlwaysOn =
        true

    // MARK: - Computed Properties

    private var versionText: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "—"
        let build = info?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            ColorPalette.backgroundPrimary.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    section(header: "Оформление") {
                        themeCard
                    }
                    section(header: "Во время задания") {
                        taskCard
                    }
                    section(header: "О приложении") {
                        aboutCard
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Layout

    private func section<Content: View>(
        header: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(header.uppercased())
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(ColorPalette.brandMuted)
                .padding(.horizontal, 12)
            content()
                .background(ColorPalette.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.gray.opacity(0.15), lineWidth: 1)
                }
        }
    }

    private func toggleRow(
        title: String,
        icon: String,
        isOn: Binding<Bool>
    ) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 16) {
                IconChip(systemName: icon, size: 36)

                Text(title)
                    .foregroundStyle(ColorPalette.textPrimary)
            }
        }
        .tint(ColorPalette.accentPrimary)
        .padding(8)
        .frame(height: 56)
    }

    // MARK: - Sections

    private var themeCard: some View {
        Picker("Тема", selection: $appColorScheme) {
            ForEach(AppColorScheme.allCases) { scheme in
                Text(scheme.title).tag(scheme)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .padding(12)
    }

    private var taskCard: some View {
        VStack(spacing: .zero) {
            toggleRow(
                title: "Звук сканирования",
                icon: "speaker.wave.2",
                isOn: $isScanSoundOn
            )
            Divider().padding(.horizontal, 16)
            toggleRow(
                title: "Не гасить экран",
                icon: "display",
                isOn: $isScreenAlwaysOn
            )
        }
        .padding(.horizontal, 4)
    }

    private var aboutCard: some View {
        MenuRow(
            title: "Версия",
            icon: "info.circle",
            value: versionText,
            showsChevron: false
        )
        .padding(.horizontal, 4)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
