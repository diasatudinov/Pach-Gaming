//
//  ParachutistNode.swift
//  Pach Gaming
//
//

import SpriteKit
import UIKit

final class ParachutistNode: SKSpriteNode {
    let shopVM = CPShopViewModel()
    private(set) var isChuteDeployed: Bool = false

    private let fallTextureName = "parachutist1_freefall"
    private let chuteTextureName = "parachutist1_parachute"

    init() {
        let defaultSize = CGSize(width: 71, height: 93)
        if let currentSkin = shopVM.currentSkinItem {
            if let _ = UIImage(named: "\(currentSkin.image)_freefall") {
                let tex = SKTexture(imageNamed: "\(currentSkin.image)_freefall")
                super.init(texture: tex, color: .clear, size: defaultSize)
            } else {
                // fallback
                super.init(texture: nil, color: .red, size: defaultSize)
            }
            
        } else {
            if let _ = UIImage(named: "parachutist1_freefall") {
                let tex = SKTexture(imageNamed: "parachutist1_freefall")
                super.init(texture: tex, color: .clear, size: defaultSize)
            } else {
                // fallback
                super.init(texture: nil, color: .red, size: defaultSize)
            }
        }
        name = "parachutist"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func deployParachute() {
        guard !isChuteDeployed else { return }
        isChuteDeployed = true
        if let currentSkin = shopVM.currentSkinItem {
            if let _ = UIImage(named: "\(currentSkin.image)_parachute") {
                texture = SKTexture(imageNamed: "\(currentSkin.image)_parachute")
                size = CGSize(width: 85, height: 120)
            } else {
                color = .green
                colorBlendFactor = 1.0
            }
        }

        physicsBody?.linearDamping = 1.4
    }
}


