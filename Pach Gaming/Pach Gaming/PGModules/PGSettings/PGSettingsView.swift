//
//  PGSettingsView.swift
//  Pach Gaming
//
//

import SwiftUI

struct PGSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
        @StateObject var settingsVM = CPSettingsViewModel()
        var body: some View {
            ZStack {
                
                VStack {
                    
                    ZStack {
                        
                        Image(.settingsBgPG)
                            .resizable()
                            .scaledToFit()
                        
                        
                        VStack(spacing:40) {
                            HStack(spacing: 40) {
                                VStack {
                                    
                                    Image(.soundsTextPG)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 80:20)
                                    
                                    HStack {
                                        
                                        Image(settingsVM.soundEnabled ? .soundIcon : .soundIconOff)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 80:70)
                                        
                                        Button {
                                            withAnimation {
                                                settingsVM.soundEnabled.toggle()
                                            }
                                        } label: {
                                            Image(settingsVM.soundEnabled ? .onPG:.offPG)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 80:70)
                                        }
                                    }
                                }
                                
                                VStack {
                                    
                                    Image(.musicTextPG)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 80:20)
                                    
                                    HStack {
                                        
                                        Image(settingsVM.musicEnabled ? .musicIconOn:.musicIconOff)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 80:70)
                                        
                                        Button {
                                            withAnimation {
                                                settingsVM.musicEnabled.toggle()
                                            }
                                        } label: {
                                            Image(settingsVM.musicEnabled ? .onPG:.offPG)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 80:70)
                                        }
                                    }
                                }
                            }
                            Image(.languageTextPG)
                                .resizable()
                                .scaledToFit()
                                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 80:80)
                    
                            
                        }.padding(.top,30)
                    }.frame(height: ZZDeviceManager.shared.deviceType == .pad ? 88:320)
                    
                }
                
                VStack {
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                            
                        } label: {
                            Image(.backIconPG)
                                .resizable()
                                .scaledToFit()
                                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:60)
                        }
                        
                        Spacer()
                        
                        ZZCoinBg()
                        
                    }.padding()
                    Spacer()
                    
                }
            }.frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        Image(.appBgZZ)
                            .resizable()
                            .ignoresSafeArea()
                            .scaledToFill()
                    }
                )
        }
    }

#Preview {
    PGSettingsView()
}
