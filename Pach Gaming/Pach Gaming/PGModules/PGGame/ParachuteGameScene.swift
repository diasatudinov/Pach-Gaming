import SpriteKit

final class ParachuteGameScene: SKScene {

    enum SceneEvent {
        case hud(String)
        case win
        case lose
    }

    var onEvent: ((SceneEvent) -> Void)?

    // MARK: - Настройки геймплея
    private let waterHeight: CGFloat = 120          // высота "воды" снизу
    private let boatSize = CGSize(width: 140, height: 50)

    private let freefallSpeed: CGFloat = 360        // px/sec без парашюта (быстро)
    private let descentSpeed: CGFloat = 110         // px/sec с парашютом (медленно)

    private let impulseStrength: CGFloat = 160      // px/sec добавка к vx от свайпа
    private let maxHorizontalSpeed: CGFloat = 240   // ограничение vx
    private let horizontalDampingPerSecond: CGFloat = 1.8 // "трение" vx

    private let windStrength: CGFloat = 55          // px/sec^2 (ускорение)
    private let windFrequency: CGFloat = 0.7        // частота "синуса" ветра

    // MARK: - Состояние уровня
    private var levelIndex: Int = 1
    private var totalParachutists: Int = 0
    private var landedCount: Int = 0
    private var isLevelActive: Bool = false

    // MARK: - Ноды
    private var waterNode: SKShapeNode!
    private var boatNode: SKShapeNode!
    private var parachutists: [ParachutistNode] = []

    // таймер для ветра
    private var t: TimeInterval = 0

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.55, green: 0.78, blue: 0.95, alpha: 1.0)
        setupStaticWorld()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutStaticWorld()
    }

    // MARK: - Public API
    func startLevel(level: Int) {
        levelIndex = level
        resetLevel()
        spawnLevel()
        isLevelActive = true
        emitHUD()
    }

    func applySwipe(deltaX: CGFloat) {
        guard isLevelActive else { return }
        let dir: CGFloat = deltaX >= 0 ? 1 : -1
        // Короткий импульс всем раскрытым в воздухе
        for p in parachutists where p.state == .parachute && !p.hasLanded {
            p.vx = clamp(p.vx + dir * impulseStrength, -maxHorizontalSpeed, maxHorizontalSpeed)
        }
    }

    // MARK: - Touches (тап по парашютисту)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isLevelActive, let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let nodesAtPoint = nodes(at: loc)

        if let p = nodesAtPoint.compactMap({ $0 as? ParachutistNode }).first {
            if p.state == .freefall {
                p.openParachute()
                emitHUD()
            }
        }
    }

    // MARK: - Update loop
    override func update(_ currentTime: TimeInterval) {
        guard isLevelActive else { return }

        // dt
        if t == 0 { t = currentTime }
        let dt = min(1.0/30.0, currentTime - t) // кап для стабильности
        t = currentTime

        // ветер (синус)
        let windAx = sin(CGFloat(currentTime) * windFrequency) * windStrength

        for p in parachutists where !p.hasLanded {
            // Вертикальная скорость задаётся состоянием (без физики)
            let vy: CGFloat = (p.state == .freefall) ? -freefallSpeed : -descentSpeed

            // горизонтальное: vx + ветер
            p.vx += windAx * CGFloat(dt)
            p.vx = clamp(p.vx, -maxHorizontalSpeed, maxHorizontalSpeed)

            // трение по vx
            let damping = max(0, 1 - horizontalDampingPerSecond * CGFloat(dt))
            p.vx *= damping

            // движение
            p.position.x += p.vx * CGFloat(dt)
            p.position.y += vy * CGFloat(dt)

            // ограничим по краям экрана
            let halfW = p.size.width * 0.5
            p.position.x = clamp(p.position.x, halfW, size.width - halfW)

            // проверки столкновений с лодкой/водой
            checkLandingOrFail(for: p)
        }
    }

    // MARK: - World setup
    private func setupStaticWorld() {
        // вода
        waterNode = SKShapeNode(rect: .zero, cornerRadius: 0)
        waterNode.fillColor = SKColor(red: 0.15, green: 0.45, blue: 0.85, alpha: 1.0)
        waterNode.strokeColor = .clear
        addChild(waterNode)

        // лодка (просто прямоугольник)
        boatNode = SKShapeNode(rectOf: boatSize, cornerRadius: 10)
        boatNode.fillColor = SKColor(red: 0.55, green: 0.30, blue: 0.10, alpha: 1.0)
        boatNode.strokeColor = .clear
        addChild(boatNode)

        layoutStaticWorld()
    }

    private func layoutStaticWorld() {
        // вода снизу
        waterNode.path = CGPath(rect: CGRect(x: 0, y: 0, width: size.width, height: waterHeight), transform: nil)
        waterNode.position = .zero

        // лодка по центру, чуть выше воды
        boatNode.position = CGPoint(x: size.width * 0.5, y: waterHeight + 40)
    }

    // MARK: - Level logic
    private func resetLevel() {
        isLevelActive = false
        landedCount = 0
        totalParachutists = 0

        for p in parachutists { p.removeFromParent() }
        parachutists.removeAll()
    }

    private func spawnLevel() {
        // 2...12, можно слегка усложнять по уровню
        totalParachutists = clampInt(2 + (levelIndex / 2), 2, 12)

        for i in 0..<totalParachutists {
            let p = ParachutistNode(
                freefallTextureName: "parachutist_freefall",
                parachuteTextureName: "parachutist_parachute"
            )

            // старт сверху, разброс по X
            let x = CGFloat.random(in: 40...(size.width - 40))
            let y = size.height + CGFloat(40 + i * 12)

            p.position = CGPoint(x: x, y: y)
            p.zPosition = 10
            addChild(p)
            parachutists.append(p)
        }
    }

    private func checkLandingOrFail(for p: ParachutistNode) {
        // 1) вода: если нижняя часть спрайта коснулась водной зоны -> поражение
        let bottomY = p.position.y - p.size.height * 0.5
        if bottomY <= waterHeight {
            loseLevel()
            return
        }

        // 2) лодка: засчитываем посадку, если спустился до высоты лодки и по X внутри лодки
        // (простая логика без физики)
        let boatTopY = boatNode.position.y + boatSize.height * 0.5
        if bottomY <= boatTopY + 6 { // небольшой допуск
            let dx = abs(p.position.x - boatNode.position.x)
            if dx <= boatSize.width * 0.5 - 10 {
                land(p)
                return
            }
        }
    }

    private func land(_ p: ParachutistNode) {
        guard !p.hasLanded else { return }
        p.hasLanded = true
        landedCount += 1

        // поставить на лодку аккуратно и "заморозить"
        p.vx = 0
        let y = boatNode.position.y + boatSize.height * 0.5 + p.size.height * 0.5 - 6
        p.position.y = y

        emitHUD()

        if landedCount >= totalParachutists {
            winLevel()
        }
    }

    private func winLevel() {
        isLevelActive = false
        onEvent?(.win)
    }

    private func loseLevel() {
        isLevelActive = false

        // (опционально) "акула" — просто всплеск/текст, без анимации
        onEvent?(.lose)
    }

    private func emitHUD() {
        let opened = parachutists.filter { $0.state == .parachute }.count
        onEvent?(.hud("Level \(levelIndex) • Landed \(landedCount)/\(totalParachutists) • Opened \(opened)"))
    }

    // MARK: - Helpers
    private func clamp(_ v: CGFloat, _ a: CGFloat, _ b: CGFloat) -> CGFloat {
        min(max(v, a), b)
    }

    private func clampInt(_ v: Int, _ a: Int, _ b: Int) -> Int {
        min(max(v, a), b)
    }
}
