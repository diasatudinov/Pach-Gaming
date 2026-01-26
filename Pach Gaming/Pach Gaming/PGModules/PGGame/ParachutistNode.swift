import SpriteKit

final class ParachutistNode: SKSpriteNode {

    enum State {
        case freefall
        case parachute
    }

    private let freefallTexture: SKTexture
    private let parachuteTexture: SKTexture

    var state: State = .freefall
    var vx: CGFloat = 0
    var hasLanded: Bool = false

    init(freefallTextureName: String, parachuteTextureName: String) {
        self.freefallTexture = SKTexture(imageNamed: freefallTextureName)
        self.parachuteTexture = SKTexture(imageNamed: parachuteTextureName)

        super.init(texture: freefallTexture, color: .clear, size: CGSize(width: 48, height: 48))
        // Если у тебя картинки другого размера — можно убрать size и оставить original:
        // super.init(texture: freefallTexture, color: .clear, size: freefallTexture.size())
        self.name = "parachutist"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func openParachute() {
        guard state == .freefall else { return }
        state = .parachute
        texture = parachuteTexture

        // чуть сбросим горизонтальную скорость, чтобы чувствовался "рывок контроля"
        vx *= 0.6
    }
}
