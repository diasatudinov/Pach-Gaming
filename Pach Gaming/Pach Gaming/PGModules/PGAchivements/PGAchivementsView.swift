//
//  PGAchivementsView.swift
//  Pach Gaming
//
//

import SwiftUI

struct PGAchivementsView: View {
    @StateObject var user = ZZUser.shared
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel = ZZAchievementsViewModel()
    @State private var index = 0
    var body: some View {
        ZStack {
            
            VStack {
                
                ZStack {
                    HStack {
                        Image(.achievementsTextPG)
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 80:48)
                    }
                    
                    HStack(alignment: .center) {
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
                        
                    }.padding(.horizontal).padding([.top])
                }
                
                VStack {
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.achievements, id: \.self) { item in
                                Image(item.isAchieved ? item.image : "\(item.image)Off")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 210)
                                    .overlay(alignment: .bottom, content: {
                                        if item.isAchieved {
                                            Image(.getBtnPG)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 70)
                                        }
                                    })
                                    .onTapGesture {
                                        if item.isAchieved {
                                            user.updateUserMoney(for: 10)
                                        }
                                        viewModel.achieveToggle(item)
                                    }
                                
                            }
                        }
                    }
                    
                }
                .frame(maxHeight: .infinity)
                
            }
        }.background(
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
    PGAchivementsView()
}
