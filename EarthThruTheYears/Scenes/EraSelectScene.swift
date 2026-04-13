import SpriteKit

class EraSelectScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = ColorPalette.menuBackground
        setupUI()
    }

    private func setupUI() {
        // Title
        let title = SKLabelNode(text: "Çağ Seçimi")
        title.fontName = Constants.fontName
        title.fontSize = 36
        title.fontColor = ColorPalette.goldColor
        title.position = CGPoint(x: size.width / 2, y: size.height - 80)
        addChild(title)

        let subtitle = SKLabelNode(text: "Hangi döneme yolculuk yapmak istiyorsun?")
        subtitle.fontName = Constants.fontNameRegular
        subtitle.fontSize = 16
        subtitle.fontColor = ColorPalette.textColor.withAlphaComponent(0.7)
        subtitle.position = CGPoint(x: size.width / 2, y: size.height - 115)
        addChild(subtitle)

        // Era cards
        let eras: [(Era, String)] = [
            (.triassic, "İlk dinozorların ortaya çıkışı"),
            (.jurassic, "Dev dinozorların hüküm sürdüğü çağ"),
            (.cretaceous, "Dinozorların son çağı")
        ]

        let cardWidth: CGFloat = 350
        let cardHeight: CGFloat = 180
        let spacing: CGFloat = 30
        let startX = size.width / 2
        let startY = size.height / 2 + 60

        for (index, (era, description)) in eras.enumerated() {
            let isUnlocked = GameManager.shared.isEraUnlocked(era)
            let y = startY - CGFloat(index) * (cardHeight + spacing) / 1.8

            let card = SKNode()
            card.position = CGPoint(x: startX, y: y)
            card.name = "era_\(era.rawValue)"

            // Card background
            let colors = ColorPalette.colors(for: era)
            let bg = SKShapeNode(rectOf: CGSize(width: cardWidth, height: cardHeight / 1.5), cornerRadius: 14)
            bg.fillColor = isUnlocked ? colors.skyBottom.withAlphaComponent(0.5) : ColorPalette.lockedColor.withAlphaComponent(0.3)
            bg.strokeColor = isUnlocked ? colors.accent : ColorPalette.lockedColor
            bg.lineWidth = 2
            bg.name = "era_\(era.rawValue)"
            card.addChild(bg)

            // Era number
            let numLabel = SKLabelNode(text: "\(index + 1). Çağ")
            numLabel.fontName = Constants.fontNameRegular
            numLabel.fontSize = 12
            numLabel.fontColor = ColorPalette.textColor.withAlphaComponent(0.6)
            numLabel.position = CGPoint(x: -cardWidth / 2 + 50, y: 30)
            card.addChild(numLabel)

            // Era name
            let nameLabel = SKLabelNode(text: era.name)
            nameLabel.fontName = Constants.fontName
            nameLabel.fontSize = 28
            nameLabel.fontColor = isUnlocked ? colors.accent : ColorPalette.lockedColor
            nameLabel.position = CGPoint(x: 0, y: 8)
            card.addChild(nameLabel)

            // Time period
            let timeLabel = SKLabelNode(text: era.subtitle)
            timeLabel.fontName = Constants.fontNameRegular
            timeLabel.fontSize = 12
            timeLabel.fontColor = ColorPalette.textColor.withAlphaComponent(0.5)
            timeLabel.position = CGPoint(x: 0, y: -12)
            card.addChild(timeLabel)

            // Description
            let descLabel = SKLabelNode(text: description)
            descLabel.fontName = Constants.fontNameRegular
            descLabel.fontSize = 13
            descLabel.fontColor = ColorPalette.textColor.withAlphaComponent(0.6)
            descLabel.position = CGPoint(x: 0, y: -35)
            card.addChild(descLabel)

            // Lock icon if not unlocked
            if !isUnlocked {
                let lock = SKLabelNode(text: "🔒")
                lock.fontSize = 30
                lock.position = CGPoint(x: cardWidth / 2 - 35, y: -5)
                card.addChild(lock)
            } else {
                // Progress indicator
                let unlocked = GameManager.shared.unlockedLevels[era] ?? 0
                let progressText = "\(min(unlocked, era.totalLevels))/\(era.totalLevels) Bölüm"
                let progressLabel = SKLabelNode(text: progressText)
                progressLabel.fontName = Constants.fontNameRegular
                progressLabel.fontSize = 12
                progressLabel.fontColor = ColorPalette.goldColor
                progressLabel.position = CGPoint(x: cardWidth / 2 - 60, y: -5)
                card.addChild(progressLabel)
            }

            addChild(card)
        }

        // Back button
        let backButton = NodeFactory.makeButton(text: "Ana Menü", size: CGSize(width: 160, height: 45))
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

            for era in Era.allCases {
                if name == "era_\(era.rawValue)" && GameManager.shared.isEraUnlocked(era) {
                    AudioManager.shared.playButtonSound(on: self)
                    GameManager.shared.currentEra = era
                    let scene = LevelSelectScene(size: size)
                    transitionTo(scene)
                    return
                }
            }

            if name == "backButton" || name.hasPrefix("Ana Menü") {
                let scene = MainMenuScene(size: size)
                transitionTo(scene)
                return
            }
        }
    }
}
