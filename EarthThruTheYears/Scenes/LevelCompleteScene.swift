import SpriteKit

class LevelCompleteScene: SKScene {

    private let goldCollected: Int
    private let minimumGold: Int

    init(size: CGSize, goldCollected: Int, minimumGold: Int) {
        self.goldCollected = goldCollected
        self.minimumGold = minimumGold
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.1, green: 0.15, blue: 0.1, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        // Victory title
        let title = SKLabelNode(text: "BÖLÜM TAMAMLANDI!")
        title.fontName = Constants.fontName
        title.fontSize = 38
        title.fontColor = ColorPalette.goldColor
        title.position = CGPoint(x: size.width / 2, y: size.height - 120)
        addChild(title)

        // Stars based on gold performance
        let starCount: Int
        if goldCollected >= minimumGold * 3 {
            starCount = 3
        } else if goldCollected >= minimumGold * 2 {
            starCount = 2
        } else {
            starCount = 1
        }

        let starsContainer = SKNode()
        starsContainer.position = CGPoint(x: size.width / 2, y: size.height - 190)
        addChild(starsContainer)

        for i in 0..<3 {
            let star = SKLabelNode(text: i < starCount ? "★" : "☆")
            star.fontSize = 45
            star.fontColor = i < starCount ? ColorPalette.goldColor : ColorPalette.lockedColor
            star.position = CGPoint(x: CGFloat(i - 1) * 55, y: 0)
            starsContainer.addChild(star)

            if i < starCount {
                star.setScale(0)
                let delay = SKAction.wait(forDuration: Double(i) * 0.3 + 0.5)
                let appear = SKAction.sequence([
                    SKAction.scale(to: 1.3, duration: 0.2),
                    SKAction.scale(to: 1.0, duration: 0.1)
                ])
                star.run(SKAction.sequence([delay, appear]))
            }
        }

        // Stats
        let goldLabel = SKLabelNode(text: "Toplanan Altın: \(goldCollected)")
        goldLabel.fontName = Constants.fontName
        goldLabel.fontSize = 22
        goldLabel.fontColor = ColorPalette.goldColor
        goldLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 20)
        addChild(goldLabel)

        let totalLabel = SKLabelNode(text: "Toplam Altın: \(GameManager.shared.totalGold)")
        totalLabel.fontName = Constants.fontNameRegular
        totalLabel.fontSize = 18
        totalLabel.fontColor = ColorPalette.textColor
        totalLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 15)
        addChild(totalLabel)

        let livesLabel = SKLabelNode(text: "Kalan Can: \(GameManager.shared.lives)")
        livesLabel.fontName = Constants.fontNameRegular
        livesLabel.fontSize = 18
        livesLabel.fontColor = ColorPalette.heartColor
        livesLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 45)
        addChild(livesLabel)

        // Buttons
        if GameManager.shared.hasNextLevel() {
            let nextButton = NodeFactory.makeButton(text: "Sonraki Bölüm", size: CGSize(width: 220, height: 55))
            nextButton.position = CGPoint(x: size.width / 2, y: 150)
            nextButton.name = "nextButton"
            addChild(nextButton)
        }

        let menuButton = NodeFactory.makeButton(text: "Bölüm Seçimi", size: CGSize(width: 220, height: 50))
        menuButton.position = CGPoint(x: size.width / 2, y: 80)
        menuButton.name = "menuButton"
        addChild(menuButton)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            let name = node.name ?? node.parent?.name ?? ""

            if name == "nextButton" || name.hasPrefix("Sonraki") {
                GameManager.shared.advanceToNextLevel()
                GameManager.shared.resetForLevel()
                let scene = GameScene(size: size)
                transitionTo(scene)
                return
            }
            if name == "menuButton" || name.hasPrefix("Bölüm Seçimi") {
                let scene = LevelSelectScene(size: size)
                transitionTo(scene)
                return
            }
        }
    }
}
