//
//  ASGRoot.swift
//  Pach Gaming
//
//


import SwiftUI

struct ASGRoot: View {
    
    @State private var isLoading = true
    @State var toUp: Bool = true
    @AppStorage("vers") var verse: Int = 0
    
    var body: some View {
        ZStack {
            if verse == 1 {
                ASGWVWrap(urlString: ASGLinks.winStarData)
            } else {
                VStack {
                    if isLoading {
                        PGLoaderView()
                    } else {
                        PGMenuView()
                            .onAppear {
                                AppDelegate.orientationLock = .portrait
                                setOrientation(.portrait)
                            }
                            .onDisappear {
                                AppDelegate.orientationLock = .all
                            }
                            
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                updateIfNeeded()
            }
           
        }
    }
    
    func updateIfNeeded() {
        if ASGLinks.shared.finalURL == nil {
            Task {
                if await !ASGResolver.checking() {
                    verse = 1
                    toUp = false
                    isLoading = false
                    
                } else {
                    verse = 0
                    toUp = true
                    isLoading = false
                }
            }
        } else {
            isLoading = false
        }
        
        
    }
    
    func setOrientation(_ orientation: UIInterfaceOrientation) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let selector = NSSelectorFromString("setInterfaceOrientation:")
            if let responder = windowScene.value(forKey: "keyWindow") as? UIResponder, responder.responds(to: selector) {
                responder.perform(selector, with: orientation.rawValue)
            }
        }
    }
}

#Preview {
    ASGRoot()
}
