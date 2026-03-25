import SpriteKit

class OptionsScene: SKScene {

    private var soundToggle: SKNode?
    private var musicToggle: SKNode?

    override func didMove(to view: SKView) {
        backgroundColor = ColorPalette.menuBackground
        setupUI()
    }

    private func setupUI() {
        // Title
        let title = SKLabelNode(text: "Ayarlar")
        title.fontName = Constants.fontName
        title.fontSize = 36
        title.fontColor = ColorPalette.goldColor
        title.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(title)

        // Sound toggle
        let soundRow = createToggleRow(
            label: "Ses Efektleri",
            isOn: SaveManager.shared.soundEnabled,
            yPos: size.height / 2 + 60,
            name: "sound"
        )
        addChild(soundRow)
        soundToggle = soundRow

        // Music toggle
        let musicRow = createToggleRow(
            label: "Müzik",
            isOn: SaveManager.shared.musicEnabled,
            yPos: size.height / 2 - 10,
            name: "music"
        )
        addChild(musicRow)
        musicToggle = musicRow

        // Reset progress button
        let resetButton = NodeFactory.makeButton(text: "İlerlemeyi Sıfırla", size: CGSize(width: 240, height: 50))
        resetButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        resetButton.name = "resetButton"
        addChild(resetButton)

        // Version info
        let version = SKLabelNode(text: "Earth Throughout the Years v1.0")
        version.fontName = Constants.fontNameRegular
        version.fontSize = 12
        version.fontColor = SKColor(white: 0.5, alpha: 1)
        version.position = CGPoint(x: size.width / 2, y: 80)
        addChild(version)

        // Back button
        let backButton = NodeFactory.makeButton(text: "Geri", size: CGSize(width: 140, height: 45))
        backButton.position = CGPoint(x: 120, y: 80)
        backButton.name = "backButton"
        addChild(backButton)
    }

    private func createToggleRow(label: String, isOn: Bool, yPos: CGFloat, name: String) -> SKNode {
        let row = SKNode()
        row.position = CGPoint(x: size.width / 2, y: yPos)
        row.name = name

        let labelNode = SKLabelNode(text: label)
        labelNode.fontName = Constants.fontName
        labelNode.fontSize = 22
        labelNode.fontColor = ColorPalette.textColor
        labelNode.horizontalAlignmentMode = .left
        labelNode.position = CGPoint(x: -160, y: -8)
        row.addChild(labelNode)

        let toggleBg = SKShapeNode(rectOf: CGSize(width: 70, height: 34), cornerRadius: 17)
        toggleBg.fillColor = isOn ? ColorPalette.buttonColor : SKColor(white: 0.3, alpha: 1)
        toggleBg.strokeColor = isOn ? ColorPalette.buttonHighlight : SKColor(white: 0.5, alpha: 1)
        toggleBg.lineWidth = 2
        toggleBg.position = CGPoint(x: 140, y: 0)
        toggleBg.name = "\(name)Toggle"
        row.addChild(toggleBg)

        let toggleCircle = SKShapeNode(circleOfRadius: 13)
        toggleCircle.fillColor = .white
        toggleCircle.strokeColor = .clear
        toggleCircle.position = CGPoint(x: isOn ? 160 : 120, y: 0)
        toggleCircle.name = "\(name)Circle"
        row.addChild(toggleCircle)

        let stateLabel = SKLabelNode(text: isOn ? "AÇIK" : "KAPALI")
        stateLabel.fontName = Constants.fontNameRegular
        stateLabel.fontSize = 11
        stateLabel.fontColor = SKColor(white: 0.6, alpha: 1)
        stateLabel.position = CGPoint(x: 140, y: -25)
        stateLabel.name = "\(name)State"
        row.addChild(stateLabel)

        return row
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            let name = node.name ?? node.parent?.name ?? ""

            if name.contains("sound") || name == "sound" {
                SaveManager.shared.soundEnabled.toggle()
                refreshUI()
                return
            }
            if name.contains("music") || name == "music" {
                SaveManager.shared.musicEnabled.toggle()
                refreshUI()
                return
            }
            if name == "resetButton" || name.hasPrefix("İlerlemeyi") {
                resetProgress()
                return
            }
            if name == "backButton" || name.hasPrefix("Geri") {
                let scene = MainMenuScene(size: size)
                transitionTo(scene)
                return
            }
        }
    }

    private func refreshUI() {
        removeAllChildren()
        setupUI()
    }

    private func resetProgress() {
        GameManager.shared.totalGold = 0
        GameManager.shared.extraLifeCounter = 0
        GameManager.shared.unlockedLevels = [.triassic: 1, .jurassic: 0, .cretaceous: 0]
        GameManager.shared.marketPurchases = []
        GameManager.shared.saveProgress()

        let label = SKLabelNode(text: "İlerleme sıfırlandı!")
        label.fontName = Constants.fontName
        label.fontSize = 22
        label.fontColor = .red
        label.position = CGPoint(x: size.width / 2, y: size.height / 2 - 160)
        label.zPosition = Constants.ZPosition.overlay
        addChild(label)

        label.run(SKAction.sequence([
            SKAction.wait(forDuration: 2),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
}
