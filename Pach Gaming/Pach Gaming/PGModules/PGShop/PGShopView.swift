//
//  PGShopView.swift
//  Pach Gaming
//
//

import SwiftUI

struct PGShopView: View {
    @StateObject var user = ZZUser.shared
        @Environment(\.presentationMode) var presentationMode
        @ObservedObject var viewModel: CPShopViewModel
        @State var category: JGItemCategory?
        var body: some View {
            ZStack {
                
                if let category = category {
                    VStack(spacing: 35) {
                        
                        Image(.shopTextPG)
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:70)
                        
                        ScrollView(.horizontal) {
                            HStack {
                                
                                ForEach(category == .skin ? viewModel.shopSkinItems :viewModel.shopBgItems, id: \.self) { item in
                                    achievementItem(item: item, category: category == .skin ? .skin : .background)
                                    
                                }
                            }
                            
                        }
                    }
                } else {
                    VStack(spacing: 35) {
                        Image(.shopTextPG)
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:70)
                        
                        HStack(spacing: 30) {
                            Button {
                                category = .skin
                            } label: {
                                Image(.skinsHeadPG)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:200)
                            }
                            
                            Button {
                                category = .background
                            } label: {
                                Image(.bgHeadPG)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:200)
                            }
                        }.frame(maxHeight: .infinity)
                        
                    }.padding()
                }
                
                
                
                VStack {
                    HStack {
                        Button {
                            if category == nil {
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                category = nil
                            }
                            
                        } label: {
                            Image(.backIconPG)
                                .resizable()
                                .scaledToFit()
                                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:65)
                        }
                        
                        Spacer()
                        
                        ZZCoinBg()
                        
                        
                        
                    }.padding()
                    Spacer()
                    
                    
                    
                }
            }.frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        if let currentBg = viewModel.currentBgItem {
                            Image(currentBg.image)
                                .resizable()
                                .scaledToFill()
                                .ignoresSafeArea()
                        }
                    }
                )
        }
        
        @ViewBuilder func achievementItem(item: JGItem, category: JGItemCategory) -> some View {
            ZStack {
                
                Image(item.icon)
                    .resizable()
                    .scaledToFit()
                VStack {
                    Spacer()
                    Button {
                        viewModel.selectOrBuy(item, user: user, category: category)
                    } label: {
                        
                        if viewModel.isPurchased(item, category: category) {
                            ZStack {
                                Image(viewModel.isCurrentItem(item: item, category: category) ? .usedBtnBgPG : .useBtnBgPG)
                                    .resizable()
                                    .scaledToFit()
                                
                            }.frame(height: ZZDeviceManager.shared.deviceType == .pad ? 50:69)
                            
                        } else {
                            Image(viewModel.isMoneyEnough(item: item, user: user, category: category) ? "hundredCoinPG" : "hundredOffCoinPG")
                                .resizable()
                                .scaledToFit()
                                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 50:69)
                        }
                        
                        
                    }
                }.offset(y: 0)
                
            }.frame(height: ZZDeviceManager.shared.deviceType == .pad ? 300:230)
            
        }
    }

#Preview {
    PGShopView(viewModel: CPShopViewModel())
}
