import SwiftUI

struct ProfileView: View {
    // MARK: - State

    @State private var viewModel: ProfileViewModel

    // MARK: - Constants

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
            .init(title: "Поддержка", icon: "questionmark.bubble")
        ]
    }

    // MARK: - Init

    init(profileService: ProfileServiceProtocol) {
        self.viewModel = .init(profileService: profileService)
    }

    // MARK: - Body

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

    }

    // MARK: - Screen States

    private var loadedProfileStack: some View {
        ZStack {
            background

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    profileHeader
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

    // MARK: - Layout

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

    // MARK: - Sections

    private var profileHeader: some View {
        HStack(alignment: .center) {
            Text("Профиль")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(ColorPalette.surfacePrimary)
                .shadow(
                    color: ColorPalette.brandPrimary.opacity(0.35),
                    radius: 4,
                    y: 2
                )
            Spacer()
            NavigationLink {
                SettingsView()
                    .toolbar(.hidden, for: .tabBar)
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(ColorPalette.surfacePrimary)
                    .shadow(
                        color: ColorPalette.brandPrimary.opacity(0.35),
                        radius: 4,
                        y: 2
                    )
            }
            .hidden()  // Settings are postponed until the app has configurable options.
        }
    }

    private var detailsSection: some View {
        section(header: "Подробнее") {
            VStack(spacing: .zero) {
                ForEach(detailsItems) { item in
                    NavigationLink {
                        if item.title == "Финансы" {
                            ProfileFinanceView(service: ProfileFinanceServiceMock())
                                .toolbar(.hidden, for: .tabBar)
                        } else {
                            SimpleBlockerView(type: .inDevelopment)
                        }
                    } label: {
                        MenuRow(
                            title: item.title,
                            icon: item.icon,
                            value: item.value
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(item.title != "Финансы")
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

    // MARK: - Profile Card

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

    // MARK: - Finance

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

    // MARK: - Formatting

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
