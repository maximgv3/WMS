import SwiftUI

struct ProfileView: View {
    private var avatarTempUrl: URL = URL(string: "https://sun9-1.userapi.com/s/v1/ig2/oNxDkf_sAkoTnFVCU3gjLTbvgc-7Luo-lyR5FUTw_fkBoaen9C0Xb7-Th1Q4LL45vPH99A_nQFMPx8nLlE6V_dO5.jpg?quality=95&as=32x43,48x64,72x96,108x144,160x213,240x320,360x480,480x640,540x720,640x853,720x960,1080x1440,1280x1707,1440x1920,1920x2560&from=bu&u=lxaomKbnmjX0juMyksVX_k_G5PuVDWboDWSd7FDbhy0&cs=1920x0")!
    private var name: String = "Гвазава Максим Александрович"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 44) {
                profileData
                financeStack
                Spacer()
                
            }
            .padding(20)
        }
    }

    private var profileData: some View {
        HStack {
            profileImage
            Spacer()
            Text(name)
                .font(.system(size: 22, weight: .bold))
                .frame(maxWidth: .infinity)
        }
    }
    
    private var financeStack: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                financeBlock(value: 5000, type: "Ожидается")
                financeBlock(value: 10000, type: "На балансе")
            }
            NavigationLink() {
            } label: {
                profileRow(title: "Подробнее", icon: "")
            }
            .buttonStyle(.plain)
        }
    }
    
    private func profileRow(title: String, icon: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(.purple)

            Text(title)
                .font(.system(size: 24))
                .foregroundStyle(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.gray.opacity(0.5))
        }
        .padding(.horizontal, 24)
        .frame(height: 72)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 16)
    }
    
    private func financeBlock(value: Int, type: String) -> some View {
        VStack(alignment: .center, spacing: 6) {
            Text(String(value) + " ₽")
                .bold()
            Text(type)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
            .fill(ColorPalette.backgroundPrimary)
        )
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
