import SwiftUI

struct ZZCoinBg: View {
    @StateObject var user = ZZUser.shared
    var height: CGFloat = ZZDeviceManager.shared.deviceType == .pad ? 80:60
    var body: some View {
        ZStack {
            Image(.coinsBgPD)
                .resizable()
                .scaledToFit()
            
            Text("\(user.money)")
                .font(.system(size: ZZDeviceManager.shared.deviceType == .pad ? 45:24, weight: .semibold))
                .foregroundStyle(.white)
                .textCase(.uppercase)
                .offset(x: -10, y: -2)
            
            
            
        }.frame(height: height)
        
    }
}

#Preview {
    ZZCoinBg()
}
