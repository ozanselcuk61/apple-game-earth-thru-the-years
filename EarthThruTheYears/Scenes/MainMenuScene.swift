import SpriteKit

class MainMenuScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = ColorPalette.menuBackground
        setupUI()
    }

    private func setupUI() {
        // Title
        let title = SKLabelNode(text: "Earth Throughout")
        title.fontName = Constants.fontName
        title.fontSize = 42
        title.fontColor = ColorPalette.goldColor
        title.position = CGPoint(x: size.width / 2, y: size.height - 120)
        addChild(title)

        let subtitle = SKLabelNode(text: "the Years")
        subtitle.fontName = Constants.fontName
        subtitle.fontSize = 42
        subtitle.fontColor = ColorPalette.goldColor
        subtitle.position = CGPoint(x: size.width / 2, y: size.height - 170)
        addChild(subtitle)

        // Subtitle - era info
        let eraInfo = SKLabelNode(text: "Dinozorlar Çağında Zaman Yolculuğu")
        eraInfo.fontName = Constants.fontNameRegular
        eraInfo.fontSize = 18
        eraInfo.fontColor = ColorPalette.textColor.withAlphaComponent(0.7)
        eraInfo.position = CGPoint(x: size.width / 2, y: size.height - 205)
        addChild(eraInfo)

        // Animated dinosaur silhouette
        let dinoSilhouette = NodeFactory.makeDinosaur(type: .tRex)
        dinoSilhouette.setScale(0.6)
        dinoSilhouette.alpha = 0.2
        dinoSilhouette.position = CGPoint(x: size.width - 180, y: 100)
        addChild(dinoSilhouette)

        // Menu buttons
        let buttonSpacing: CGFloat = 60
        let startY = size.height / 2 + 60

        let playButton = NodeFactory.makeButton(text: "Maceraya Başla")
        playButton.position = CGPoint(x: size.width / 2, y: startY)
        playButton.name = "playButton"
        addChild(playButton)

        let characterButton = NodeFactory.makeButton(text: "Karakter Seçimi")
        characterButton.position = CGPoint(x: size.width / 2, y: startY - buttonSpacing)
        characterButton.name = "characterButton"
        addChild(characterButton)

        let marketButton = NodeFactory.makeButton(text: "Market")
        marketButton.position = CGPoint(x: size.width / 2, y: startY - buttonSpacing * 2)
        marketButton.name = "marketButton"
        addChild(marketButton)

        let optionsButton = NodeFactory.makeButton(text: "Ayarlar")
        optionsButton.position = CGPoint(x: size.width / 2, y: startY - buttonSpacing * 3)
        optionsButton.name = "optionsButton"
        addChild(optionsButton)

        // Gold display
        let goldBg = SKShapeNode(rectOf: CGSize(width: 140, height: 36), cornerRadius: 8)
        goldBg.fillColor = SKColor(white: 0.1, alpha: 0.6)
        goldBg.strokeColor = ColorPalette.goldColor.withAlphaComponent(0.5)
        goldBg.lineWidth = 1
        goldBg.position = CGPoint(x: size.width - 100, y: size.height - 40)
        addChild(goldBg)

        let goldLabel = SKLabelNode(text: "💰 \(GameManager.shared.totalGold)")
        goldLabel.fontName = Constants.fontName
        goldLabel.fontSize = 18
        goldLabel.fontColor = ColorPalette.goldColor
        goldLabel.verticalAlignmentMode = .center
        goldLabel.position = CGPoint(x: size.width - 100, y: size.height - 40)
        addChild(goldLabel)

        // Character display
        let currentChar = GameManager.shared.selectedCharacter
        let charLabel = SKLabelNode(text: "Karakter: \(currentChar == .boy ? "Erkek" : "Kız")")
        charLabel.fontName = Constants.fontNameRegular
        charLabel.fontSize = 14
        charLabel.fontColor = ColorPalette.textColor.withAlphaComponent(0.6)
        charLabel.position = CGPoint(x: 120, y: size.height - 40)
        addChild(charLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            let name = node.name ?? node.parent?.name ?? ""

            if name == "playButton" || name.hasPrefix("Maceraya Başla") {
                AudioManager.shared.playButtonSound(on: self)
                let scene = EraSelectScene(size: size)
                transitionTo(scene)
                return
            }
            if name == "characterButton" || name.hasPrefix("Karakter Seçimi") {
                AudioManager.shared.playButtonSound(on: self)
                let scene = CharacterSelectScene(size: size)
                transitionTo(scene)
                return
            }
            if name == "marketButton" || name.hasPrefix("Market") {
                AudioManager.shared.playButtonSound(on: self)
                let scene = MarketScene(size: size)
                transitionTo(scene)
                return
            }
            if name == "optionsButton" || name.hasPrefix("Ayarlar") {
                AudioManager.shared.playButtonSound(on: self)
                let scene = OptionsScene(size: size)
                transitionTo(scene)
                return
            }
        }
    }
}
