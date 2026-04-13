import SpriteKit

class LevelSelectScene: SKScene {

    private let era: Era

    override init(size: CGSize) {
        self.era = GameManager.shared.currentEra
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        let colors = ColorPalette.colors(for: era)
        backgroundColor = colors.skyBottom.withAlphaComponent(0.5)
        setupUI()
    }

    private func setupUI() {
        let colors = ColorPalette.colors(for: era)

        // Title
        let title = SKLabelNode(text: "\(era.name) Dönemi")
        title.fontName = Constants.fontName
        title.fontSize = 34
        title.fontColor = colors.accent
        title.position = CGPoint(x: size.width / 2, y: size.height - 80)
        addChild(title)

        let subtitle = SKLabelNode(text: era.subtitle)
        subtitle.fontName = Constants.fontNameRegular
        subtitle.fontSize = 14
        subtitle.fontColor = ColorPalette.textColor.withAlphaComponent(0.6)
        subtitle.position = CGPoint(x: size.width / 2, y: size.height - 110)
        addChild(subtitle)

        // Level buttons in a Mario-style path
        let levelPositions: [CGPoint] = [
            CGPoint(x: size.width * 0.2, y: size.height * 0.5),
            CGPoint(x: size.width * 0.4, y: size.height * 0.6),
            CGPoint(x: size.width * 0.6, y: size.height * 0.45),
            CGPoint(x: size.width * 0.8, y: size.height * 0.55)
        ]

        let unlockedLevel = GameManager.shared.unlockedLevels[era] ?? 0

        // Draw path between levels
        let pathShape = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: levelPositions[0])
        for i in 1..<levelPositions.count {
            path.addLine(to: levelPositions[i])
        }
        pathShape.path = path
        pathShape.strokeColor = SKColor(white: 0.5, alpha: 0.4)
        pathShape.lineWidth = 4
        pathShape.lineCap = .round
        pathShape.zPosition = -1
        addChild(pathShape)

        for i in 0..<4 {
            let level = i + 1
            let isUnlocked = level <= unlockedLevel
            let pos = levelPositions[i]

            let levelNode = SKNode()
            levelNode.position = pos
            levelNode.name = "level_\(level)"

            // Circle background
            let circle = SKShapeNode(circleOfRadius: 40)
            circle.fillColor = isUnlocked ? colors.accent : ColorPalette.lockedColor
            circle.strokeColor = isUnlocked ? colors.accent.withAlphaComponent(0.8) : ColorPalette.lockedColor.withAlphaComponent(0.5)
            circle.lineWidth = 3
            circle.name = "level_\(level)"
            levelNode.addChild(circle)

            if isUnlocked {
                // Level number
                let label = SKLabelNode(text: "\(level)")
                label.fontName = Constants.fontName
                label.fontSize = 30
                label.fontColor = .white
                label.verticalAlignmentMode = .center
                label.name = "level_\(level)"
                levelNode.addChild(label)

                // Show level data
                let levelData = LevelCatalog.level(era: era, subLevel: level)
                let infoLabel = SKLabelNode(text: "🪙 \(levelData.minimumGold) gerekli")
                infoLabel.fontName = Constants.fontNameRegular
                infoLabel.fontSize = 11
                infoLabel.fontColor = ColorPalette.goldColor
                infoLabel.position = CGPoint(x: 0, y: -55)
                levelNode.addChild(infoLabel)
            } else {
                let lock = SKLabelNode(text: "🔒")
                lock.fontSize = 28
                lock.verticalAlignmentMode = .center
                levelNode.addChild(lock)
            }

            // Level name
            let nameLabel = SKLabelNode(text: "Bölüm \(level)")
            nameLabel.fontName = Constants.fontNameRegular
            nameLabel.fontSize = 13
            nameLabel.fontColor = ColorPalette.textColor
            nameLabel.position = CGPoint(x: 0, y: 50)
            levelNode.addChild(nameLabel)

            // Boss indicator for level 4
            if level == 4 {
                let bossLabel = SKLabelNode(text: "⭐ BOSS")
                bossLabel.fontName = Constants.fontName
                bossLabel.fontSize = 11
                bossLabel.fontColor = .red
                bossLabel.position = CGPoint(x: 0, y: -70)
                levelNode.addChild(bossLabel)
            }

            addChild(levelNode)
        }

        // Decorative dinosaur
        let types = DinosaurFactory.dinosaurTypes(for: era)
        if let firstType = types.first {
            let deco = NodeFactory.makeDinosaur(type: firstType)
            deco.setScale(0.5)
            deco.alpha = 0.3
            deco.position = CGPoint(x: size.width - 100, y: 80)
            addChild(deco)
        }

        // Back button
        let backButton = NodeFactory.makeButton(text: "Geri", size: CGSize(width: 140, height: 45))
        backButton.position = CGPoint(x: 120, y: 110)
        backButton.name = "backButton"
        addChild(backButton)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            let name = node.name ?? node.parent?.name ?? ""

            for level in 1...4 {
                if name == "level_\(level)" && GameManager.shared.isLevelUnlocked(era: era, level: level) {
                    AudioManager.shared.playButtonSound(on: self)
                    GameManager.shared.currentLevel = level
                    GameManager.shared.resetForLevel()
                    GameManager.shared.resetForNewGame()
                    let scene = GameScene(size: size)
                    transitionTo(scene)
                    return
                }
            }

            if name == "backButton" || name.hasPrefix("Geri") {
                let scene = EraSelectScene(size: size)
                transitionTo(scene)
                return
            }
        }
    }
}
