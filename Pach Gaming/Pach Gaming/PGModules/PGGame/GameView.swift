//
//  GameView.swift
//  Pach Gaming
//
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: CPShopViewModel
    @State private var result: GameResult = .playing
    @State private var scene: ReactionLandingScene = {
        let s = ReactionLandingScene()
        s.scaleMode = .resizeFill
        s.backgroundColor = .clear
        return s
    }()
    
    @State private var showInfo = false
    var body: some View {
        ZStack {
            
            if let currentBg = viewModel.currentBgItem {
                Image(currentBg.image)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            
            SpriteViewContainer(scene: scene)
                .ignoresSafeArea()
                .onAppear {
                    // Подписка на результат из SpriteKit
                    scene.onResultChanged = { newResult in
                        DispatchQueue.main.async {
                            self.result = newResult
                        }
                    }
                }
            VStack {
                HStack {
                    
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(.backIconPG)
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:65)
                    }
                    Spacer()
                    
                    Button {
                        showInfo = true
                    } label: {
                        Image(.infoIconPG)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 70)
                    }
                }.padding()
                Spacer()
            }
            
            if result == .win || result == .lose {
                Color.black.opacity(0.7).ignoresSafeArea()
                
                Image(result == .win ? .winImagePG : .loseImagePG)
                    .resizable()
                    .scaledToFit()
                    .padding(25)
                    .overlay(alignment: .bottom) {
                        HStack {
                            if result == .win {
                                VStack {
                                    Image(.coinsIconPG)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:65)
                                    
                                    HStack {
                                        Button {
                                            presentationMode.wrappedValue.dismiss()
                                        } label: {
                                            Image(.winHomeIconPG)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:65)
                                        }
                                        
                                        Button {
                                            scene.restart()
                                        } label: {
                                            Image(.nextIconPG)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 70)
                                        }
                                    }
                                }
                                
                            } else {
                                Button {
                                    presentationMode.wrappedValue.dismiss()
                                } label: {
                                    Image(.loseHomeIconPG)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:65)
                                }
                                
                                Button {
                                    scene.restart()
                                } label: {
                                    Image(.loseRestartIconPG)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 70)
                                }
                                
                            }
                        }
                    }
            }
            
            if showInfo {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    
                    Image(.instructionImagePG)
                        .resizable()
                        .scaledToFit()
                }.onTapGesture {
                    showInfo = false
                    scene.restart()
                }
            }
        }
    }
}

enum GameResult: Equatable {
    case playing
    case win
    case lose
}

#Preview {
    GameView(viewModel: CPShopViewModel())
}
