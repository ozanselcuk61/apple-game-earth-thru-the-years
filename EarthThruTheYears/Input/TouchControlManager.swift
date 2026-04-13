import SpriteKit

class TouchControlManager: SKNode {

    private(set) var inputState = InputState()

    private let dpadNode: SKNode
    private let dpadBg: SKShapeNode
    private let jumpButton: SKShapeNode
    private let dpadRadius: CGFloat = 75
    private let jumpRadius: CGFloat = 55

    private var dpadTouch: UITouch?
    private var jumpTouch: UITouch?
    private var dpadCenter: CGPoint = .zero

    override init() {
        dpadNode = SKNode()
        dpadBg = SKShapeNode(circleOfRadius: 75)
        jumpButton = SKShapeNode(circleOfRadius: 55)
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        zPosition = Constants.ZPosition.hud
        // DO NOT set isUserInteractionEnabled - GameScene will forward touches

        // D-pad (left side of screen) - bigger and higher
        dpadBg.fillColor = SKColor(white: 0.3, alpha: 0.35)
        dpadBg.strokeColor = SKColor(white: 0.5, alpha: 0.5)
        dpadBg.lineWidth = 3
        dpadNode.addChild(dpadBg)

        // Direction arrows - bigger
        let leftArrow = SKLabelNode(text: "◀")
        leftArrow.fontSize = 32
        leftArrow.fontColor = SKColor(white: 1, alpha: 0.6)
        leftArrow.position = CGPoint(x: -40, y: -10)
        dpadNode.addChild(leftArrow)

        let rightArrow = SKLabelNode(text: "▶")
        rightArrow.fontSize = 32
        rightArrow.fontColor = SKColor(white: 1, alpha: 0.6)
        rightArrow.position = CGPoint(x: 40, y: -10)
        dpadNode.addChild(rightArrow)

        let indicator = SKShapeNode(circleOfRadius: 22)
        indicator.fillColor = SKColor(white: 0.6, alpha: 0.6)
        indicator.strokeColor = .clear
        indicator.name = "indicator"
        dpadNode.addChild(indicator)

        dpadNode.position = CGPoint(x: -490, y: -190)
        dpadCenter = dpadNode.position
        addChild(dpadNode)

        // Jump button (right side) - bigger and higher
        jumpButton.fillColor = SKColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 0.4)
        jumpButton.strokeColor = SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.7)
        jumpButton.lineWidth = 3

        let jumpLabel = SKLabelNode(text: "ZIPLA")
        jumpLabel.fontName = Constants.fontName
        jumpLabel.fontSize = 20
        jumpLabel.fontColor = SKColor(white: 1, alpha: 0.9)
        jumpLabel.verticalAlignmentMode = .center
        jumpButton.addChild(jumpLabel)

        jumpButton.position = CGPoint(x: 490, y: -190)
        addChild(jumpButton)
    }

    // MARK: - Called by GameScene

    func handleTouchBegan(_ touch: UITouch, in node: SKNode) {
        let location = touch.location(in: self)

        if location.x < 0 && dpadTouch == nil {
            dpadTouch = touch
            updateDpadFromLocation(location)
        } else if location.x > 0 && jumpTouch == nil {
            jumpTouch = touch
            inputState.jumpPressed = true
            jumpButton.fillColor = SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.7)
        }
    }

    func handleTouchMoved(_ touch: UITouch, in node: SKNode) {
        if touch === dpadTouch {
            let location = touch.location(in: self)
            updateDpadFromLocation(location)
        }
    }

    func handleTouchEnded(_ touch: UITouch) {
        if touch === dpadTouch {
            dpadTouch = nil
            inputState.horizontalDirection = 0
            if let indicator = dpadNode.childNode(withName: "indicator") {
                indicator.position = .zero
            }
        }
        if touch === jumpTouch {
            jumpTouch = nil
            inputState.jumpPressed = false
            jumpButton.fillColor = SKColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 0.4)
        }
    }

    private func updateDpadFromLocation(_ location: CGPoint) {
        let dx = location.x - dpadCenter.x
        let distance = abs(dx)

        if distance > 10 {
            inputState.horizontalDirection = (dx / dpadRadius).clamped(to: -1...1)
        } else {
            inputState.horizontalDirection = 0
        }

        if let indicator = dpadNode.childNode(withName: "indicator") {
            let clampedX = dx.clamped(to: -dpadRadius...dpadRadius)
            indicator.position = CGPoint(x: clampedX, y: 0)
        }
    }

    func postUpdate() {
        // Reserved for future use
    }
}
