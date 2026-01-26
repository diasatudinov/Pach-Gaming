import SwiftUI
import SpriteKit

struct SpriteKitContainerView: UIViewRepresentable {
    let scene: SKScene

    func makeUIView(context: Context) -> SKView {
        let skView = SKView()

        skView.allowsTransparency = true
        skView.isOpaque = false
        skView.backgroundColor = .clear

        scene.backgroundColor = .clear
        scene.scaleMode = .resizeFill

        skView.presentScene(scene)
        return skView
    }

    func updateUIView(_ skView: SKView, context: Context) {
        // На всякий случай поддерживаем настройки при обновлениях SwiftUI
        skView.allowsTransparency = true
        skView.isOpaque = false
        skView.backgroundColor = .clear

        scene.backgroundColor = .clear

        if skView.scene !== scene {
            skView.presentScene(scene)
        }
    }
}