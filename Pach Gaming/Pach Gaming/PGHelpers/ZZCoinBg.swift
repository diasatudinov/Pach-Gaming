//
//  ZZCoinBg.swift
//  Pach Gaming
//
//


import SwiftUI

struct ZZCoinBg: View {
    @StateObject var user = ZZUser.shared
    var height: CGFloat = ZZDeviceManager.shared.deviceType == .pad ? 80:62
    var body: some View {
        ZStack {
            Image("coinsBgZZ")
                .resizable()
                .scaledToFit()
            
            Text("\(user.money)")
                .font(.system(size: ZZDeviceManager.shared.deviceType == .pad ? 45:28, weight: .bold))
                .foregroundStyle(.white)
                .textCase(.uppercase)
                .offset(x: 15, y: 2)
            
            
            
        }.frame(height: height)
        
    }
}

#Preview {
    ZZCoinBg()
}
