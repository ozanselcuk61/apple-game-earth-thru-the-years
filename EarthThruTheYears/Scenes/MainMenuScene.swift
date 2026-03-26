import SpriteKit

class MainMenuScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = ColorPalette.menuBackground
        setupUI()
    }

    private func setupUI() {
        // Title - single line, centered
        let title = SKLabelNode(text: "Earth Throughout the Years")
        title.fontName = Constants.fontName
        title.fontSize = 34
        title.fontColor = ColorPalette.goldColor
        title.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(title)

        // Subtitle
        let eraInfo = SKLabelNode(text: "Dinozorlar Çağında Zaman Yolculuğu")
        eraInfo.fontName = Constants.fontNameRegular
        eraInfo.fontSize = 16
        eraInfo.fontColor = ColorPalette.textColor.withAlphaComponent(0.7)
        eraInfo.position = CGPoint(x: size.width / 2, y: size.height - 135)
        addChild(eraInfo)

        // Menu buttons - compact layout
        let buttonSpacing: CGFloat = 55
        let startY = size.height / 2 + 50

        let playButton = NodeFactory.makeButton(text: "Maceraya Başla", size: CGSize(width: 240, height: 50))
        playButton.position = CGPoint(x: size.width / 2, y: startY)
        playButton.name = "playButton"
        addChild(playButton)

        let characterButton = NodeFactory.makeButton(text: "Karakter Seçimi", size: CGSize(width: 240, height: 50))
        characterButton.position = CGPoint(x: size.width / 2, y: startY - buttonSpacing)
        characterButton.name = "characterButton"
        addChild(characterButton)

        let marketButton = NodeFactory.makeButton(text: "Market", size: CGSize(width: 240, height: 50))
        marketButton.position = CGPoint(x: size.width / 2, y: startY - buttonSpacing * 2)
        marketButton.name = "marketButton"
        addChild(marketButton)

        let optionsButton = NodeFactory.makeButton(text: "Ayarlar", size: CGSize(width: 240, height: 50))
        optionsButton.position = CGPoint(x: size.width / 2, y: startY - buttonSpacing * 3)
        optionsButton.name = "optionsButton"
        addChild(optionsButton)

        // Gold display (top right, safely inside)
        let goldBg = SKShapeNode(rectOf: CGSize(width: 130, height: 32), cornerRadius: 8)
        goldBg.fillColor = SKColor(white: 0.1, alpha: 0.6)
        goldBg.strokeColor = ColorPalette.goldColor.withAlphaComponent(0.5)
        goldBg.lineWidth = 1
        goldBg.position = CGPoint(x: size.width - 120, y: size.height - 80)
        addChild(goldBg)

        let goldLabel = SKLabelNode(text: "\(GameManager.shared.totalGold) Altın")
        goldLabel.fontName = Constants.fontName
        goldLabel.fontSize = 16
        goldLabel.fontColor = ColorPalette.goldColor
        goldLabel.verticalAlignmentMode = .center
        goldLabel.position = CGPoint(x: size.width - 120, y: size.height - 80)
        addChild(goldLabel)

        // Character display (top left, safely inside)
        let currentChar = GameManager.shared.selectedCharacter
        let charLabel = SKLabelNode(text: "Karakter: \(currentChar == .boy ? "Erkek" : "Kız")")
        charLabel.fontName = Constants.fontNameRegular
        charLabel.fontSize = 13
        charLabel.fontColor = ColorPalette.textColor.withAlphaComponent(0.6)
        charLabel.position = CGPoint(x: 140, y: size.height - 80)
        addChild(charLabel)

        // Decorative dino (bottom right)
        let dinoSilhouette = NodeFactory.makeDinosaur(type: .tRex)
        dinoSilhouette.setScale(0.5)
        dinoSilhouette.alpha = 0.15
        dinoSilhouette.position = CGPoint(x: size.width - 200, y: 140)
        addChild(dinoSilhouette)
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
