import SpriteKit

class HUD: SKNode {

    private let livesLabel = SKLabelNode()
    private let goldLabel = SKLabelNode()
    private let levelLabel = SKLabelNode()
    private var heartNodes: [SKShapeNode] = []
    private let progressBar: SKShapeNode
    private let progressFill: SKCropNode
    private let progressFillBar: SKSpriteNode

    private let barWidth: CGFloat = 200
    private let barHeight: CGFloat = 12

    override init() {
        progressBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 6)
        progressFill = SKCropNode()
        progressFillBar = SKSpriteNode(color: ColorPalette.buttonColor,
                                        size: CGSize(width: barWidth - 4, height: barHeight - 4))
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        zPosition = Constants.ZPosition.hud

        // Gold icon + label (top left)
        let coinIcon = SKShapeNode(circleOfRadius: 10)
        coinIcon.fillColor = ColorPalette.goldColor
        coinIcon.strokeColor = SKColor(red: 0.8, green: 0.65, blue: 0, alpha: 1)
        coinIcon.lineWidth = 2
        coinIcon.position = CGPoint(x: -580, y: 320)
        addChild(coinIcon)

        goldLabel.fontName = Constants.fontName
        goldLabel.fontSize = 20
        goldLabel.fontColor = ColorPalette.textColor
        goldLabel.horizontalAlignmentMode = .left
        goldLabel.verticalAlignmentMode = .center
        goldLabel.position = CGPoint(x: -565, y: 320)
        addChild(goldLabel)

        // Level label (top center)
        levelLabel.fontName = Constants.fontName
        levelLabel.fontSize = 18
        levelLabel.fontColor = ColorPalette.textColor
        levelLabel.horizontalAlignmentMode = .center
        levelLabel.verticalAlignmentMode = .center
        levelLabel.position = CGPoint(x: 0, y: 320)
        addChild(levelLabel)

        // Progress bar (top center, below level label)
        progressBar.fillColor = SKColor(white: 0.2, alpha: 0.6)
        progressBar.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        progressBar.lineWidth = 1
        progressBar.position = CGPoint(x: 0, y: 295)
        addChild(progressBar)

        progressFillBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        progressFillBar.position = CGPoint(x: -(barWidth - 4) / 2, y: 0)
        progressFill.addChild(progressFillBar)

        let maskNode = SKSpriteNode(color: .white, size: CGSize(width: barWidth - 4, height: barHeight - 4))
        progressFill.maskNode = maskNode
        progressFill.position = CGPoint(x: 0, y: 295)
        addChild(progressFill)

        // Hearts for lives (top right)
        updateLives(Constants.startingLives)
        updateGold(0)
        updateLevel(era: .triassic, level: 1)
    }

    private var currentDisplayedLives: Int = -1

    func updateLives(_ lives: Int) {
        guard lives != currentDisplayedLives else { return }
        currentDisplayedLives = lives

        // Remove old hearts and labels
        heartNodes.forEach { $0.removeFromParent() }
        heartNodes.removeAll()
        for i in 0..<10 {
            childNode(withName: "heartLabel_\(i)")?.removeFromParent()
        }

        for i in 0..<lives {
            let heart = SKShapeNode(rectOf: CGSize(width: 18, height: 16), cornerRadius: 4)
            heart.fillColor = ColorPalette.heartColor
            heart.strokeColor = .clear
            heart.position = CGPoint(x: 500 + CGFloat(i) * 25, y: 320)
            addChild(heart)
            heartNodes.append(heart)

            let label = SKLabelNode(text: "♥")
            label.fontSize = 20
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: 500 + CGFloat(i) * 25, y: 320)
            label.name = "heartLabel_\(i)"
            addChild(label)
        }

        livesLabel.text = "x\(lives)"
    }

    private var currentDisplayedGold: Int = -1

    func updateGold(_ gold: Int) {
        guard gold != currentDisplayedGold else { return }
        currentDisplayedGold = gold
        goldLabel.text = " \(gold)"
    }

    func updateLevel(era: Era, level: Int) {
        levelLabel.text = "\(era.name) - Bölüm \(level)"
    }

    func updateProgress(_ progress: CGFloat) {
        let clampedProgress = progress.clamped(to: 0...1)
        progressFillBar.xScale = clampedProgress
    }

    private var currentGoldReqValue: Int = -1

    func showGoldRequirement(current: Int, required: Int) {
        guard current != currentGoldReqValue else { return }
        currentGoldReqValue = current

        childNode(withName: "goldReq")?.removeFromParent()

        let reqLabel = SKLabelNode(text: "Gereken Altın: \(current)/\(required)")
        reqLabel.fontName = Constants.fontNameRegular
        reqLabel.fontSize = 14
        reqLabel.fontColor = current >= required ? .green : ColorPalette.goldColor
        reqLabel.position = CGPoint(x: 0, y: 275)
        reqLabel.name = "goldReq"
        addChild(reqLabel)
    }

    func showExtraLifeAnimation() {
        let label = SKLabelNode(text: "+1 CAN!")
        label.fontName = Constants.fontName
        label.fontSize = 30
        label.fontColor = ColorPalette.heartColor
        label.position = CGPoint(x: 0, y: 0)
        addChild(label)

        let anim = SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 80, duration: 1.0),
                SKAction.fadeOut(withDuration: 1.0),
                SKAction.scale(to: 1.5, duration: 1.0)
            ]),
            SKAction.removeFromParent()
        ])
        label.run(anim)
    }
}
