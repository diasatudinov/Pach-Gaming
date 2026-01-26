//
//  PGMenuView.swift
//  Pach Gaming
//
//

import SwiftUI

struct PGMenuView: View {
    @State private var showGame = false
    @State private var showAchievement = false
    @State private var showSettings = false
    @State private var showCalendar = false
    @State private var showDailyReward = false
    @State private var showShop = false
    
    @StateObject private var shopVM = CPShopViewModel()
    var body: some View {
        
        ZStack {
            
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    ZZCoinBg()
                        .frame(maxHeight: .infinity, alignment: .top)
                    
                    Button {
                        showShop = true
                    } label: {
                        Image("shopIconZZ")
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:77)
                    }
                }
                
                VStack(spacing: 10) {
                    
                    
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 10) {
                    Button {
                        showSettings = true
                    } label: {
                        Image("settingsIconZZ")
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:82)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    
                    Button {
                        showAchievement = true
                    } label: {
                        Image("achivementsIconZZ")
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:87)
                    }
                }
                
            }
            .padding(5)
            
            VStack(spacing: 10) {
                Image("menuLogoZZ")
                    .resizable()
                    .scaledToFit()
                    .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 140:170)
                
                Button {
                    showGame = true
                } label: {
                    Image("playIconZZ")
                        .resizable()
                        .scaledToFit()
                        .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:150)
                }
                
            }
            
        }.frame(maxWidth: .infinity)
            .background(
                ZStack {
                    Image(.appBgZZ)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .scaledToFill()
                }
            )
            .fullScreenCover(isPresented: $showGame) {
                GameView(viewModel: shopVM)
            }
            .fullScreenCover(isPresented: $showShop) {
                PGShopView(viewModel: shopVM)
            }
            .fullScreenCover(isPresented: $showSettings) {
                PGSettingsView()
            }
            .fullScreenCover(isPresented: $showAchievement) {
                PGAchivementsView()
            }
        
    }
}

#Preview {
    PGMenuView()
}
