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
            
//        @StateObject private var settingsVM = CPSettingsViewModel()
        var body: some View {
            
            ZStack {
                    
                    VStack(spacing: 124) {
                        
                        
                        Image("menuLogoPD")
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 140:190)
                        
                        
                        VStack(spacing: 32) {
                            
                            Button {
                                showGame = true
                            } label: {
                                Image(".playIconPD")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:70)
                            }
                            
                            Button {
                                showSettings = true
                            } label: {
                                Image(".settingsconPD")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:70)
                            }
                                                
                            Button {
                                showAchievement = true
                            } label: {
                                Image(".achievementsconPD")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:70)
                            }
                        }
                        
                    }
        
                
            }.frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        Image(".appBgPD")
                            .resizable()
                            .edgesIgnoringSafeArea(.all)
                            .scaledToFill()
                    }
                )
                .fullScreenCover(isPresented: $showGame) {
//                    BeetleColorPuzzleView()
                }
                .fullScreenCover(isPresented: $showAchievement) {
//                    PDAchievementsView()
                }
            
        }
    }

#Preview {
    PGMenuView()
}
