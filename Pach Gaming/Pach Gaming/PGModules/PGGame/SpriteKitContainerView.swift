//
//  SpriteKitContainerView.swift
//  Pach Gaming
//
//


import SwiftUI
import SpriteKit


struct SpriteViewContainer: UIViewRepresentable {
    var scene: ReactionLandingScene

    func makeUIView(context: Context) -> SKView {
        let skView = SKView(frame: UIScreen.main.bounds)
        skView.backgroundColor = .clear
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        uiView.frame = UIScreen.main.bounds
    }
}
