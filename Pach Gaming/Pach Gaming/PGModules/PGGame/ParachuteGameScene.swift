//
//  ParachuteGameScene.swift
//  Pach Gaming
//
//


import SpriteKit
import SwiftUI

final class ReactionLandingScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Public HUD bindings
    private(set) var landedCount: Int = 0
    let targetCount: Int = 5
    private(set) var stateText: String? = "Тап: раскрыть парашют • Свайп: толчок"

    // MARK: - Gameplay nodes
    private var boat: SKSpriteNode!
    private var water: SKNode!
    private var shark: SKSpriteNode?

    private var waterHitNode: SKSpriteNode!
    private var waterDecor: SKSpriteNode!
    private var debugShowWaterHitbox = false
    
    private var currentParachutist: ParachutistNode?

    // Touch handling (свайп)
    private var touchStartPoint: CGPoint?
    private var touchStartTime: TimeInterval?

    // Game state
    private var isLevelActive = true

    // MARK: - Physics categories
    private struct Category {
        static let none: UInt32 = 0
        static let parachutist: UInt32 = 1 << 0
        static let boat: UInt32       = 1 << 1
        static let water: UInt32      = 1 << 2
    }

    // MARK: - Tuning constants
    private let freeFallGravity: CGFloat = -4.5
    private let chuteGravity: CGFloat = -1.2

    private let maxDownSpeedFree: CGFloat = 260     // терминалка в свободном падении
    private let maxDownSpeedChute: CGFloat = 120
    private let fallSpeedFree: CGFloat = 260
    private let fallSpeedChute: CGFloat = 120
    
    private let swipeImpulse: CGFloat = 40.0
    private let swipeThreshold: CGFloat = 35.0

    private let boatSpeed: CGFloat = 180.0 // px/sec
    private var boatDirection: CGFloat = 1.0

    // “ветер” — лёгкий постоянный дрейф
    private let windStrength: CGFloat = 6.0

    var onResultChanged: ((GameResult) -> Void)?

    private func setResult(_ r: GameResult) {
        onResultChanged?(r)
    }
    
    // MARK: - Scene lifecycle
    override func didMove(to view: SKView) {
        view.allowsTransparency = true
        backgroundColor = .clear

        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: freeFallGravity)

        removeAllChildren()
        createWorld()
        restart()
    }
    
    

    func restart() {
        isLevelActive = true
        setResult(.playing)
        stateText = "Тап: раскрыть парашют • Свайп: толчок"

        landedCount = 0
        currentParachutist?.removeFromParent()
        currentParachutist = nil

        shark?.removeFromParent()
        shark = nil

        spawnNextParachutist()
    }

    private func applyFixedVerticalSpeed() {
        guard let p = currentParachutist, let body = p.physicsBody else { return }
        let dy = -(p.isChuteDeployed ? fallSpeedChute : fallSpeedFree)
        body.velocity = CGVector(dx: body.velocity.dx, dy: dy)
    }
    
    // MARK: - World
    private func createWorld() {
        // 1) ДЕКОРАТИВНАЯ ВОДА (картинка, без физики)
        let decorHeight: CGFloat = max(150, size.height * 0.22)
        let decorY: CGFloat = max(20, size.height * 0.06) // чуть выше низа

        if let _ = UIImage(named: "water_bg") {
            waterDecor = SKSpriteNode(imageNamed: "water_bg")
            waterDecor.size = CGSize(width: size.width, height: decorHeight)
        } else {
            // fallback
            waterDecor = SKSpriteNode(color: SKColor(red: 0.08, green: 0.45, blue: 0.75, alpha: 0.65),
                                      size: CGSize(width: size.width, height: decorHeight))
        }

        waterDecor.anchorPoint = CGPoint(x: 0.5, y: 0.0) // низ спрайта у Y
        waterDecor.position = CGPoint(x: size.width * 0.5, y: decorY)
        waterDecor.zPosition = 0
        addChild(waterDecor)

        // 2) “СМЕРТЕЛЬНАЯ” ВОДА (хитбокс) — тонкая полоска в зоне воды
        // ВАЖНО: хитбокс лучше сделать чуть НИЖЕ верхней кромки декора,
        // чтобы визуально игрок видел воду, но “смерть” происходила при касании воды.
        let hitHeight: CGFloat = 24
        let hitY = decorY + 8  // подними/опусти: чем выше — тем раньше проигрыш

        if let _ = UIImage(named: "water_hit") {
            waterHitNode = SKSpriteNode(imageNamed: "water_hit")
            waterHitNode.size = CGSize(width: size.width, height: decorHeight)
        } else {
            // fallback
            waterHitNode = SKSpriteNode(color: SKColor(red: 0.08, green: 0.45, blue: 0.75, alpha: 0.65),
                                      size: CGSize(width: size.width, height: decorHeight))
        }
        waterHitNode.position = CGPoint(x: size.width * 0.5, y: hitY)
        waterHitNode.zPosition = 1
        addChild(waterHitNode)

        let hitSize = CGSize(width: size.width, height: hitHeight)

        if debugShowWaterHitbox {
            let hitVis = SKShapeNode(rectOf: hitSize)
            hitVis.fillColor = .red.withAlphaComponent(0.25)
            hitVis.strokeColor = .red.withAlphaComponent(0.6)
            hitVis.zPosition = 10
            waterHitNode.addChild(hitVis)
        }

        waterHitNode.physicsBody = SKPhysicsBody(rectangleOf: hitSize)
        waterHitNode.physicsBody?.isDynamic = false
        waterHitNode.physicsBody?.categoryBitMask = Category.water
        waterHitNode.physicsBody?.contactTestBitMask = Category.parachutist
        waterHitNode.physicsBody?.collisionBitMask = Category.none

        // 3) ЛОДКА
        boat = makeBoatNode()
        boat.zPosition = 3
        addChild(boat)
    }

    private func makeBoatNode() -> SKSpriteNode {
        let boatSize = CGSize(width: 99, height: 77)
        let y = waterHitNode.position.y + waterHitNode.bounds.size.height * 0.25

        let node: SKSpriteNode
        if let _ = UIImage(named: "boat") {
            node = SKSpriteNode(imageNamed: "boat")
            node.size = boatSize
        } else {
            // fallback
            node = SKSpriteNode(color: .brown, size: boatSize)
        }

        node.position = CGPoint(x: size.width * 0.5, y: y)

        node.physicsBody = SKPhysicsBody(rectangleOf: boatSize)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = Category.boat
        node.physicsBody?.contactTestBitMask = Category.parachutist
        node.physicsBody?.collisionBitMask = Category.none

        return node
    }

    // MARK: - Spawning
    private func spawnNextParachutist() {
        guard isLevelActive else { return }

        if landedCount >= targetCount {
            // Победа
            isLevelActive = false
            ZZUser.shared.updateUserMoney(for: 10)
            setResult(.win)
            return
        }

        let spawnX = CGFloat.random(in: size.width * 0.2 ... size.width * 0.8)
        let spawnY = size.height + 80

        let p = ParachutistNode()
        p.position = CGPoint(x: spawnX, y: spawnY)
        p.zPosition = 3

        // Physics
        p.physicsBody = SKPhysicsBody(rectangleOf: p.size)
        p.physicsBody?.allowsRotation = false
        p.physicsBody?.linearDamping = 2.2
        p.physicsBody?.friction = 0.0
        p.physicsBody?.restitution = 0.0

        p.physicsBody?.categoryBitMask = Category.parachutist
        p.physicsBody?.contactTestBitMask = Category.boat | Category.water
        p.physicsBody?.collisionBitMask = Category.none

        addChild(p)
        currentParachutist = p
    }

    // MARK: - Input (tap + swipe via touches)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isLevelActive, let touch = touches.first else { return }
        let loc = touch.location(in: self)

        touchStartPoint = loc
        touchStartTime = touch.timestamp

        // ТАП: если тап по парашютисту — раскрываем парашют
        if let p = currentParachutist, p.contains(loc) {
            if !p.isChuteDeployed {
                p.deployParachute()

                physicsWorld.gravity = CGVector(dx: 0, dy: chuteGravity)

                // мгновенно уменьшаем скорость падения в момент раскрытия
                if let body = p.physicsBody {
                    let limitedDy = max(body.velocity.dy, -maxDownSpeedChute)
                    body.velocity = CGVector(dx: body.velocity.dx * 0.6, dy: limitedDy)
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isLevelActive, let touch = touches.first else { return }
        let end = touch.location(in: self)

        guard let start = touchStartPoint else { return }
        let dx = end.x - start.x
        let adx = abs(dx)

        // СВАЙП: горизонтальный импульс
        if adx >= swipeThreshold {
            applyHorizontalImpulse(dx: dx)
        }

        touchStartPoint = nil
        touchStartTime = nil
    }

    private func applyHorizontalImpulse(dx: CGFloat) {
        guard let p = currentParachutist else { return }

        // направление: -1 или +1
        let dir: CGFloat = dx > 0 ? 1 : -1
        let impulse = CGVector(dx: dir * swipeImpulse, dy: 0)

        p.physicsBody?.applyImpulse(impulse)
    }

    // MARK: - Update loop
    override func update(_ currentTime: TimeInterval) {
        guard isLevelActive else { return }

        moveBoat(dt: 1.0 / 60.0) // SpriteKit update не даёт dt напрямую — берём “приближённо”
        applyWind()
        clampParachutistInsideScreen()
        limitParachutistVerticalSpeed()
        applyFixedVerticalSpeed()

    }

    private func limitParachutistVerticalSpeed() {
        guard let p = currentParachutist, let body = p.physicsBody else { return }

        let maxDown = p.isChuteDeployed ? maxDownSpeedChute : maxDownSpeedFree
        if body.velocity.dy < -maxDown {
            body.velocity = CGVector(dx: body.velocity.dx, dy: -maxDown)
        }
    }
    
    private func moveBoat(dt: CGFloat) {
        // Двигаем лодку между левым и правым краем
        let halfW = boat.size.width / 2
        let minX = halfW + 12
        let maxX = size.width - halfW - 12

        boat.position.x += boatDirection * boatSpeed * dt

        if boat.position.x <= minX {
            boat.position.x = minX
            boatDirection = 1
        } else if boat.position.x >= maxX {
            boat.position.x = maxX
            boatDirection = -1
        }
    }

    private func applyWind() {
        // лёгкий дрейф только когда парашют раскрыт
        guard let p = currentParachutist, p.isChuteDeployed else { return }
        p.physicsBody?.applyForce(CGVector(dx: windStrength, dy: 0))
    }

    private func clampParachutistInsideScreen() {
        guard let p = currentParachutist else { return }
        let halfW = p.size.width / 2
        let minX = halfW + 4
        let maxX = size.width - halfW - 4
        if p.position.x < minX { p.position.x = minX }
        if p.position.x > maxX { p.position.x = maxX }
    }

    // MARK: - Contacts
    func didBegin(_ contact: SKPhysicsContact) {
        guard isLevelActive else { return }

        let a = contact.bodyA.categoryBitMask
        let b = contact.bodyB.categoryBitMask

        let isParachutist = (a == Category.parachutist) || (b == Category.parachutist)
        guard isParachutist else { return }

        if (a == Category.water) || (b == Category.water) {
            onHitWater(at: contact.contactPoint)
        } else if (a == Category.boat) || (b == Category.boat) {
            onLandBoat()
        }
    }

    private func onHitWater(at point: CGPoint) {
        // Мгновенное поражение
        isLevelActive = false
        setResult(.lose)

        if let p = currentParachutist {
            p.physicsBody?.categoryBitMask = Category.none
            p.physicsBody?.contactTestBitMask = Category.none
            p.physicsBody?.collisionBitMask = Category.none
            p.removeFromParent()
            currentParachutist = nil
        }
        
        let s: SKSpriteNode
        if let _ = UIImage(named: "shark") {
            s = SKSpriteNode(imageNamed: "shark")
            s.size = CGSize(width: 215, height: 165)
        } else {
            s = SKSpriteNode(color: .gray, size: CGSize(width: 90, height: 60))
        }
        s.position = CGPoint(x: point.x, y: max(point.y, 40))
        s.zPosition = 4
        addChild(s)
        shark = s
    }

    private func onLandBoat() {
        guard let p = currentParachutist else { return }

        // Считаем приземление только если парашют раскрыт (по желанию)
        // Если хочешь засчитывать и без парашюта — убери эту проверку.
        guard p.isChuteDeployed else { return }

        landedCount += 1

        // убрать текущего, вернуть гравитацию на free fall для следующего
        p.removeFromParent()
        currentParachutist = nil
        physicsWorld.gravity = CGVector(dx: 0, dy: freeFallGravity)

        // следующий
        run(.sequence([
            .wait(forDuration: 0.25),
            .run { [weak self] in self?.spawnNextParachutist() }
        ]))
    }
}
