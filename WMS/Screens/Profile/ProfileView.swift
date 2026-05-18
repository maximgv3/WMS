import SwiftUI

struct ProfileView: View {
    private var avatarTempUrl: URL = URL(string: "https://sun9-1.userapi.com/s/v1/ig2/oNxDkf_sAkoTnFVCU3gjLTbvgc-7Luo-lyR5FUTw_fkBoaen9C0Xb7-Th1Q4LL45vPH99A_nQFMPx8nLlE6V_dO5.jpg?quality=95&as=32x43,48x64,72x96,108x144,160x213,240x320,360x480,480x640,540x720,640x853,720x960,1080x1440,1280x1707,1440x1920,1920x2560&from=bu&u=lxaomKbnmjX0juMyksVX_k_G5PuVDWboDWSd7FDbhy0&cs=1920x0")!
    private var name: String = "Гвазава Максим Александрович"
    private var id: String = "1 023 780"
    private var iconBackground: Color { ColorPalette.accentPrimary.opacity(0.18) }
    var body: some View {
        NavigationStack {
            ZStack {
                background
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Профиль")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(ColorPalette.surfacePrimary)
                        profileCard
                        financeStack
                        Spacer()
                    }
                    .padding(20)
                }
            }
        }
    }

    private var background: some View {
        VStack {
            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 24, bottomTrailingRadius: 16, topTrailingRadius: 0, style: .continuous)
                .foregroundStyle(ColorPalette.brandPrimary)
                .ignoresSafeArea()
                .frame(maxHeight: 200)
            Spacer()
        }
        .background(ColorPalette.backgroundPrimary)
    }
    
    private var profileCard: some View {
        VStack {
            HStack(spacing: 20) {
                profileImage
                VStack(alignment: .leading, spacing: 8) {
                    Text(name)
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
                    Text("17 мая 2026, 15:12")
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
                financeBlock(value: 5000, type: "Ожидается", icon: "creditcard")
                financeBlock(value: 10000, type: "Баланс", icon: "rublesign.circle")
            }
        }
    }
    private func profileRow(title: String, icon: String?, value: String? = nil, ) -> some View {
        HStack(spacing: 16) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(ColorPalette.accentPrimary)
            }
            Text(title)
                .font(.system(size: 20))
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray.opacity(0.5))
        }
        .padding(12)
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func subRow(title: String, icon: String?) -> some View {
        HStack(spacing: 16) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 28))
            }
            Text(title)
                .font(.system(size: 20))
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    private func financeBlock(value: Int, type: String, icon: String) -> some View {
        HStack() {
            Image(systemName: icon)
                .frame(width: 40, height: 40)
                .background(iconBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text(type)
                    .font(.system(size: 13))
                    .foregroundStyle(ColorPalette.brandMuted)
                Text(String(value) + " ₽")
                    .font(.system(size: 22, weight: .semibold))
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
        AsyncImage(url: avatarTempUrl, transaction: Transaction(animation: .easeInOut(duration: 0.25))) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)
            default:
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(ColorPalette.brandMuted)
            }
        }
        .frame(width: 90, height: 90)
        .clipShape(Circle())
    }
}

#Preview {
    ProfileView()
}
