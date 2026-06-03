import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @State private var isSettingsPresented = false
    private var id: String = "1 023 780"
    private var iconBackground: Color {
        ColorPalette.accentPrimary.opacity(0.18)
    }
    private var detailsItems: [ProfileMenuItem] {
        [
            .init(title: "Финансы", icon: "creditcard"),
            .init(
                title: "Рейтинг",
                icon: "star",
                value: viewModel.profile?.rating.formatted()
            ),
            .init(title: "Документы", icon: "doc.text"),
            .init(title: "Тарифы", icon: "shippingbox"),
        ]
    }

    init(profileService: ProfileServiceProtocol) {
        self.viewModel = .init(profileService: profileService)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.profile == nil {
                    loadingState
                        .transition(.opacity)
                } else if viewModel.errorMessage != nil
                    && viewModel.profile == nil
                {
                    errorState
                        .transition(
                            .opacity.combined(with: .scale(scale: 0.98))
                        )
                } else {
                    loadedProfileStack
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: viewModel.isLoading)
            .animation(
                .easeInOut(duration: 0.25),
                value: viewModel.errorMessage
            )
            .animation(
                .easeInOut(duration: 0.25),
                value: viewModel.profile != nil
            )
        }
        .task {
            await viewModel.loadProfile()
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView()
        }
    }

    private var loadedProfileStack: some View {
        ZStack {
            background
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    HStack(alignment: .center) {
                        Text("Профиль")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(ColorPalette.surfacePrimary)
                        Spacer()
                        Button {
                            isSettingsPresented = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(ColorPalette.surfacePrimary)
                        }
                    }
                    profileCard
                    section(header: "Финансы") {
                        financeStack
                    }
                    detailsSection
                    Spacer()
                }
                .padding(20)
            }
            .refreshable {
                await viewModel.loadProfile()
            }
        }
    }

    private var loadingState: some View {
        ZStack {
            ColorPalette.backgroundPrimary.ignoresSafeArea()
            ProgressView()
                .controlSize(.large)
                .tint(ColorPalette.brandMuted)
        }
    }

    private var errorState: some View {
        ZStack {
            ColorPalette.backgroundPrimary.ignoresSafeArea()
            VStack(spacing: 32) {
                Text("Не удалось загрузить профиль")
                    .font(.system(size: 22, weight: .semibold))
                Button("Попробовать снова") {
                    Task {
                        await viewModel.loadProfile()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(ColorPalette.accentPrimary)
                .foregroundStyle(ColorPalette.brandPrimary)
                .bold()
            }
        }
    }

    private var detailsSection: some View {
        section(header: "Подробнее") {
            VStack(spacing: .zero) {
                ForEach(detailsItems) { item in
                    NavigationLink {
                        InDevelopmentView()
                    } label: {
                        profileRow(
                            title: item.title,
                            icon: item.icon,
                            value: item.value
                        )
                    }
                    .buttonStyle(.plain)

                    if item.id != detailsItems.last?.id {
                        Divider().padding(.horizontal, 16)
                    }
                }
            }
            .padding(.horizontal, 4)
            .background(ColorPalette.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.gray.opacity(0.15), lineWidth: 1)
            }
        }
    }

    private var background: some View {
        VStack {
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 24,
                bottomTrailingRadius: 16,
                topTrailingRadius: 0,
                style: .continuous
            )
            .foregroundStyle(ColorPalette.brandPrimary)
            .ignoresSafeArea()
            .frame(maxHeight: 200)
            Spacer()
        }
        .background(ColorPalette.backgroundPrimary)
    }

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
        }
    }

    private var profileCard: some View {
        VStack {
            HStack(spacing: 20) {
                profileImage
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.profile?.name ?? "")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(ColorPalette.brandPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .layoutPriority(1)
                    HStack {
                        Group {
                            Image(systemName: "person.text.rectangle")
                            Text("id: " + id)
                        }
                        .font(.system(size: 15))
                        .foregroundStyle(ColorPalette.brandPrimary)
                    }
                    .padding(5)
                    .background(iconBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Spacer()
            }
            .padding(12)
            Divider()
                .padding(.horizontal, 16)
            HStack {
                Group {
                    Image(systemName: "clock")
                    Text(formattedDate(viewModel.lastUpdateDate))
                }
                .font(.system(size: 13))
                .foregroundStyle(ColorPalette.brandMuted)
                Spacer()
            }
            .padding(.top, 8)
            .padding(.bottom, 14)
            .padding(.horizontal, 16)
        }
        .padding(8)
        .background(ColorPalette.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.gray.opacity(0.15), lineWidth: 1)
        }
    }

    private var financeStack: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                financeBlock(
                    value: viewModel.profile?.pendingFunds ?? 0,
                    type: "Ожидается",
                    icon: "creditcard"
                )
                financeBlock(
                    value: viewModel.profile?.balanceFunds ?? 0,
                    type: "Баланс",
                    icon: "rublesign.circle"
                )
            }
        }
    }
    private func profileRow(title: String, icon: String?, value: String? = nil)
        -> some View
    {
        HStack(spacing: 16) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .frame(width: 36, height: 36)
                    .foregroundStyle(ColorPalette.brandPrimary)
                    .background(iconBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            Text(title)
                .foregroundStyle(ColorPalette.brandPrimary)
            Spacer()
            if let value {
                Text(value)
                    .foregroundStyle(ColorPalette.brandMuted)
            }
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray.opacity(0.5))
        }
        .padding(8)
        .frame(height: 56)
        .background(ColorPalette.surfacePrimary)
    }

    private func financeBlock(value: Int, type: String, icon: String)
        -> some View
    {
        HStack {
            Image(systemName: icon)
                .frame(width: 40, height: 40)
                .background(iconBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text(type)
                    .font(.system(size: 13))
                    .foregroundStyle(ColorPalette.brandMuted)
                Text(formattedRubles(value))
                    .font(.system(size: 22, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .layoutPriority(1)
            }
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(ColorPalette.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.gray.opacity(0.15), lineWidth: 1)
        }
    }

    private var profileImage: some View {
        AsyncImage(
            url: viewModel.profile?.imageUrl,
            transaction: Transaction(animation: .easeInOut(duration: 0.25))
        ) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)
            default:
                avatarPlaceholder
            }
        }
        .frame(width: 90, height: 90)
        .clipShape(Circle())
    }

    private var avatarPlaceholder: some View {
        ZStack {
            Circle()
                .fill(iconBackground)
            Image(systemName: "person.circle")
                .font(.system(size: 66, weight: .light))
                .foregroundStyle(ColorPalette.brandPrimary)
        }
    }

    private func formattedRubles(_ value: Int) -> String {
        value.formatted(
            .number
                .locale(Locale(identifier: "ru_RU"))
                .grouping(.automatic)
        ) + " ₽"
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(
            .dateTime
                .locale(Locale(identifier: "ru_RU"))
                .day()
                .month(.wide)
                .year()
                .hour()
                .minute()
        )
    }

}

#Preview {
    ProfileView(profileService: ProfileServiceMock())
}

private struct ProfileMenuItem: Identifiable {
    var id: String { title }
    let title: String
    let icon: String
    let value: String?

    init(title: String, icon: String, value: String? = nil) {
        self.title = title
        self.icon = icon
        self.value = value
    }
}
