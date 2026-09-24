import SwiftUI

struct ProfileView: View {
    // MARK: - State

    @State private var viewModel: ProfileViewModel
    @State private var isSignOutConfirmationPresented = false
    @Environment(SessionStore.self) private var sessionStore
    @Environment(ActiveTaskStore.self) private var activeTaskStore

    // MARK: - Constants

    private var iconBackground: Color {
        ColorPalette.surfaceChip
    }
    private var detailsItems: [ProfileMenuItem] {
        [
            .init(title: .profileFinances, icon: "creditcard", destination: .finances),
            .init(
                title: .profileRating,
                icon: "star",
                value: viewModel.profile?.rating.formatted(),
                destination: .rating
            ),
            .init(title: .profileDocuments, icon: "doc.text", destination: .documents),
            .init(title: .profileTariffs, icon: "shippingbox", destination: .tariffs),
            .init(title: .profileSupport, icon: "questionmark.bubble", destination: .support)
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
            .navigationTitle(.profileTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ProfileDestination.self) { item in
                destination(for: item)
            }
            .toolbar(.hidden, for: .navigationBar)
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
                    section(header: .profileFinances) {
                        financeStack
                    }
                    detailsSection
                    signOutSection
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
                Text(.profileCouldNotLoadProfile)
                    .font(.system(size: 22, weight: .semibold))
                PrimaryButton(.commonTryAgain, variant: .capsule) {
                    Task {
                        await viewModel.loadProfile()
                    }
                }
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
        header: LocalizedStringResource,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(header)
                .textCase(.uppercase)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(ColorPalette.brandMuted)
                .padding(.horizontal, 12)
            content()
        }
    }

    // MARK: - Sections

    private var profileHeader: some View {
        HStack(alignment: .center) {
            Text(.profileTitle)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(ColorPalette.textInverted)
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
                    .foregroundStyle(ColorPalette.textInverted)
                    .shadow(
                        color: ColorPalette.brandPrimary.opacity(0.35),
                        radius: 4,
                        y: 2
                    )
            }
        }
    }

    private var detailsSection: some View {
        section(header: .profileMore) {
            VStack(spacing: .zero) {
                ForEach(detailsItems) { item in
                    NavigationLink(value: item.destination) {
                        MenuRow(
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

    private var signOutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                isSignOutConfirmationPresented = true
            } label: {
                MenuRow(
                    title: .profileHandInDevice,
                    icon: "rectangle.portrait.and.arrow.right",
                    showsChevron: false
                )
                .padding(.horizontal, 4)
                .background(ColorPalette.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.gray.opacity(0.15), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .disabled(activeTaskStore.activeOperation != nil)
            .opacity(activeTaskStore.activeOperation != nil ? 0.5 : 1)

            if let operation = activeTaskStore.activeOperation {
                Text(
                    .profileFinishTaskToSignOut(
                        String(localized: operation.title)
                    )
                )
                .font(.system(size: 14))
                .foregroundStyle(ColorPalette.brandMuted)
                .padding(.horizontal, 12)
            }
        }
        .confirmationDialog(
            .profileHandInDevice,
            isPresented: $isSignOutConfirmationPresented
        ) {
            Button(role: .destructive) {
                sessionStore.signOut()
            } label: {
                Text(.profileHandInDevice)
            }
        }
    }

    @ViewBuilder
    private func destination(for item: ProfileDestination) -> some View {
        Group {
            switch item {
            case .finances:
                ProfileFinanceView(service: ProfileFinanceServiceMock())
            case .rating:
                ProfileRatingView(service: ProfileRatingServiceMock())
            case .documents:
                DocumentsView(service: DocumentsServiceMock())
            case .tariffs:
                TariffsView(service: TariffsServiceMock())
            case .support:
                SupportView(service: SupportServiceMock())
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        VStack {
            HStack(spacing: 20) {
                profileImage
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.profile?.name ?? "")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(ColorPalette.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .layoutPriority(1)
                    HStack {
                        Group {
                            Image(systemName: "person.text.rectangle")
                            Text(.profileEmployeeId(sessionStore.badgeId ?? ""))
                        }
                        .font(.system(size: 15))
                        .foregroundStyle(ColorPalette.textPrimary)
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
                    Text(viewModel.lastUpdateDate.formattedAsProfileTimestamp())
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
                .foregroundStyle(ColorPalette.textPrimary)
        }
    }

    // MARK: - Finance

    private var financeStack: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                financeBlock(
                    value: viewModel.profile?.pendingFundsKopecks ?? 0,
                    type: .profilePending,
                    icon: "creditcard"
                )
                financeBlock(
                    value: viewModel.profile?.balanceFundsKopecks ?? 0,
                    type: .profileBalance,
                    icon: "rublesign.circle"
                )
            }
        }
    }

    private func financeBlock(
        value: Int,
        type: LocalizedStringResource,
        icon: String
    )
        -> some View
    {
        HStack {
            IconChip(systemName: icon, size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(type)
                    .font(.system(size: 13))
                    .foregroundStyle(ColorPalette.brandMuted)
                Text(value.formattedAsRubles())
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
}

#Preview {
    ProfileView(profileService: ProfileServiceMock())
        .environment(SessionStore())
        .environment(ActiveTaskStore())
}

private enum ProfileDestination: Hashable {
    case finances
    case rating
    case documents
    case tariffs
    case support
}

private struct ProfileMenuItem: Identifiable {
    var id: String { icon }
    let title: LocalizedStringResource
    let icon: String
    let value: String?
    let destination: ProfileDestination?

    init(
        title: LocalizedStringResource,
        icon: String,
        value: String? = nil,
        destination: ProfileDestination? = nil
    ) {
        self.title = title
        self.icon = icon
        self.value = value
        self.destination = destination
    }
}
