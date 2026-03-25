import SpriteKit

class CharacterSelectScene: SKScene {

    private var selectedType: CharacterType = GameManager.shared.selectedCharacter
    private var boyPreview: SKNode?
    private var girlPreview: SKNode?
    private var selectionIndicator: SKShapeNode?

    override func didMove(to view: SKView) {
        backgroundColor = ColorPalette.menuBackground
        setupUI()
    }

    private func setupUI() {
        // Title
        let title = SKLabelNode(text: "Karakter Seçimi")
        title.fontName = Constants.fontName
        title.fontSize = 36
        title.fontColor = ColorPalette.goldColor
        title.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(title)

        let subtitle = SKLabelNode(text: "Maceranı seninle paylaşacak kahramanını seç!")
        subtitle.fontName = Constants.fontNameRegular
        subtitle.fontSize = 16
        subtitle.fontColor = ColorPalette.textColor.withAlphaComponent(0.7)
        subtitle.position = CGPoint(x: size.width / 2, y: size.height - 140)
        addChild(subtitle)

        // Boy option
        let boyContainer = SKNode()
        boyContainer.position = CGPoint(x: size.width / 2 - 160, y: size.height / 2)
        boyContainer.name = "boyOption"
        addChild(boyContainer)

        let boyBg = SKShapeNode(rectOf: CGSize(width: 200, height: 280), cornerRadius: 16)
        boyBg.fillColor = SKColor(white: 0.15, alpha: 0.8)
        boyBg.strokeColor = ColorPalette.boyColor.withAlphaComponent(0.5)
        boyBg.lineWidth = 2
        boyBg.name = "boyOption"
        boyContainer.addChild(boyBg)

        let boyChar = NodeFactory.makePlayer(type: .boy)
        boyChar.setScale(2.0)
        boyChar.position = CGPoint(x: 0, y: 20)
        boyContainer.addChild(boyChar)
        boyPreview = boyChar

        let boyLabel = SKLabelNode(text: "Erkek Çocuk")
        boyLabel.fontName = Constants.fontName
        boyLabel.fontSize = 18
        boyLabel.fontColor = ColorPalette.boyColor
        boyLabel.position = CGPoint(x: 0, y: -100)
        boyContainer.addChild(boyLabel)

        // Girl option
        let girlContainer = SKNode()
        girlContainer.position = CGPoint(x: size.width / 2 + 160, y: size.height / 2)
        girlContainer.name = "girlOption"
        addChild(girlContainer)

        let girlBg = SKShapeNode(rectOf: CGSize(width: 200, height: 280), cornerRadius: 16)
        girlBg.fillColor = SKColor(white: 0.15, alpha: 0.8)
        girlBg.strokeColor = ColorPalette.girlColor.withAlphaComponent(0.5)
        girlBg.lineWidth = 2
        girlBg.name = "girlOption"
        girlContainer.addChild(girlBg)

        let girlChar = NodeFactory.makePlayer(type: .girl)
        girlChar.setScale(2.0)
        girlChar.position = CGPoint(x: 0, y: 20)
        girlContainer.addChild(girlChar)
        girlPreview = girlChar

        let girlLabel = SKLabelNode(text: "Kız Çocuk")
        girlLabel.fontName = Constants.fontName
        girlLabel.fontSize = 18
        girlLabel.fontColor = ColorPalette.girlColor
        girlLabel.position = CGPoint(x: 0, y: -100)
        girlContainer.addChild(girlLabel)

        // Selection indicator
        let indicator = SKShapeNode(rectOf: CGSize(width: 210, height: 290), cornerRadius: 18)
        indicator.fillColor = .clear
        indicator.strokeColor = ColorPalette.goldColor
        indicator.lineWidth = 4
        indicator.glowWidth = 3
        indicator.name = "indicator"
        addChild(indicator)
        selectionIndicator = indicator
        updateSelection()

        // Robot companion preview + label (bottom center area)
        let robotPreview = NodeFactory.makeRobot()
        robotPreview.setScale(1.2)
        robotPreview.position = CGPoint(x: size.width / 2, y: size.height * 0.18)
        addChild(robotPreview)

        let robotLabel = SKLabelNode(text: "Rehber Robot - Seni her yerde takip edecek!")
        robotLabel.fontName = Constants.fontNameRegular
        robotLabel.fontSize = 13
        robotLabel.fontColor = ColorPalette.robotAccent
        robotLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.10)
        addChild(robotLabel)

        // Back button
        let backButton = NodeFactory.makeButton(text: "Geri", size: CGSize(width: 140, height: 45))
        backButton.position = CGPoint(x: size.width * 0.15, y: size.height * 0.18)
        backButton.name = "backButton"
        addChild(backButton)

        // Confirm button
        let confirmButton = NodeFactory.makeButton(text: "Onayla", size: CGSize(width: 160, height: 50))
        confirmButton.position = CGPoint(x: size.width * 0.85, y: size.height * 0.18)
        confirmButton.name = "confirmButton"
        addChild(confirmButton)
    }

    private func updateSelection() {
        let targetX = selectedType == .boy ? size.width / 2 - 160 : size.width / 2 + 160
        let moveAction = SKAction.move(to: CGPoint(x: targetX, y: size.height / 2), duration: 0.2)
        moveAction.timingMode = .easeOut
        selectionIndicator?.run(moveAction)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            let name = node.name ?? node.parent?.name ?? ""

            if name == "boyOption" {
                selectedType = .boy
                updateSelection()
                return
            }
            if name == "girlOption" {
                selectedType = .girl
                updateSelection()
                return
            }
            if name == "backButton" || name.hasPrefix("Geri") {
                let scene = MainMenuScene(size: size)
                transitionTo(scene)
                return
            }
            if name == "confirmButton" || name.hasPrefix("Onayla") {
                GameManager.shared.selectedCharacter = selectedType
                GameManager.shared.saveProgress()
                let scene = MainMenuScene(size: size)
                transitionTo(scene)
                return
            }
        }
    }
}
