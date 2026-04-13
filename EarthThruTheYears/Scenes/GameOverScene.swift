import SpriteKit

class GameOverScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.15, green: 0.05, blue: 0.05, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        // Game Over title
        let title = SKLabelNode(text: "OYUN BİTTİ")
        title.fontName = Constants.fontName
        title.fontSize = 44
        title.fontColor = ColorPalette.heartColor
        title.position = CGPoint(x: size.width / 2, y: size.height - 150)
        addChild(title)

        // Skull/sad emoji
        let emoji = SKLabelNode(text: "💀")
        emoji.fontSize = 60
        emoji.position = CGPoint(x: size.width / 2, y: size.height / 2 + 40)
        addChild(emoji)

        // Stats
        let goldLabel = SKLabelNode(text: "Bu Bölümde Toplanan: \(GameManager.shared.levelGold) altın")
        goldLabel.fontName = Constants.fontNameRegular
        goldLabel.fontSize = 18
        goldLabel.fontColor = ColorPalette.goldColor
        goldLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 30)
        addChild(goldLabel)

        let totalLabel = SKLabelNode(text: "Toplam Altın: \(GameManager.shared.totalGold)")
        totalLabel.fontName = Constants.fontNameRegular
        totalLabel.fontSize = 16
        totalLabel.fontColor = ColorPalette.textColor.withAlphaComponent(0.7)
        totalLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 60)
        addChild(totalLabel)

        // Retry button
        let retryButton = NodeFactory.makeButton(text: "Tekrar Dene", size: CGSize(width: 220, height: 55))
        retryButton.position = CGPoint(x: size.width / 2, y: 240)
        retryButton.name = "retryButton"
        addChild(retryButton)

        // Menu button
        let menuButton = NodeFactory.makeButton(text: "Ana Menü", size: CGSize(width: 220, height: 50))
        menuButton.position = CGPoint(x: size.width / 2, y: 160)
        menuButton.name = "menuButton"
        addChild(menuButton)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            let name = node.name ?? node.parent?.name ?? ""

            if name == "retryButton" || name.hasPrefix("Tekrar") {
                GameManager.shared.resetForLevel()
                GameManager.shared.resetForNewGame()
                let scene = GameScene(size: size)
                transitionTo(scene)
                return
            }
            if name == "menuButton" || name.hasPrefix("Ana Menü") {
                let scene = MainMenuScene(size: size)
                transitionTo(scene)
                return
            }
        }
    }
}
