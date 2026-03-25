import SpriteKit

class TouchControlManager: SKNode {

    private(set) var inputState = InputState()

    private let dpadNode: SKNode
    private let jumpButton: SKShapeNode
    private let dpadRadius: CGFloat = 60

    private var dpadTouch: UITouch?
    private var jumpTouch: UITouch?
    private var dpadCenter: CGPoint = .zero
    private var previousJumpPressed = false

    override init() {
        dpadNode = SKNode()
        jumpButton = SKShapeNode(circleOfRadius: 40)
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        zPosition = Constants.ZPosition.hud
        isUserInteractionEnabled = true

        // D-pad (left side of screen)
        let dpadBg = SKShapeNode(circleOfRadius: dpadRadius)
        dpadBg.fillColor = SKColor(white: 0.3, alpha: 0.3)
        dpadBg.strokeColor = SKColor(white: 0.5, alpha: 0.4)
        dpadBg.lineWidth = 2
        dpadNode.addChild(dpadBg)

        // Direction arrows
        let leftArrow = SKLabelNode(text: "◀")
        leftArrow.fontSize = 24
        leftArrow.fontColor = SKColor(white: 1, alpha: 0.5)
        leftArrow.position = CGPoint(x: -35, y: -8)
        dpadNode.addChild(leftArrow)

        let rightArrow = SKLabelNode(text: "▶")
        rightArrow.fontSize = 24
        rightArrow.fontColor = SKColor(white: 1, alpha: 0.5)
        rightArrow.position = CGPoint(x: 35, y: -8)
        dpadNode.addChild(rightArrow)

        let indicator = SKShapeNode(circleOfRadius: 18)
        indicator.fillColor = SKColor(white: 0.6, alpha: 0.5)
        indicator.strokeColor = .clear
        indicator.name = "indicator"
        dpadNode.addChild(indicator)

        dpadNode.position = CGPoint(x: -520, y: -280)
        addChild(dpadNode)

        // Jump button (right side of screen)
        jumpButton.fillColor = SKColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 0.4)
        jumpButton.strokeColor = SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.6)
        jumpButton.lineWidth = 3

        let jumpLabel = SKLabelNode(text: "ZIPLA")
        jumpLabel.fontName = Constants.fontName
        jumpLabel.fontSize = 16
        jumpLabel.fontColor = SKColor(white: 1, alpha: 0.8)
        jumpLabel.verticalAlignmentMode = .center
        jumpButton.addChild(jumpLabel)

        jumpButton.position = CGPoint(x: 520, y: -280)
        addChild(jumpButton)
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)

            if location.x < 0 && dpadTouch == nil {
                // Left side - D-pad
                dpadTouch = touch
                dpadCenter = dpadNode.position
                updateDpad(touch: touch)
            } else if location.x > 0 && jumpTouch == nil {
                // Right side - Jump
                jumpTouch = touch
                inputState.jumpPressed = true
                inputState.jumpJustPressed = !previousJumpPressed
                jumpButton.fillColor = SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.6)
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch === dpadTouch {
                updateDpad(touch: touch)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
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
                inputState.jumpJustPressed = false
                jumpButton.fillColor = SKColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 0.4)
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    private func updateDpad(touch: UITouch) {
        let location = touch.location(in: self)
        let dx = location.x - dpadCenter.x
        let distance = abs(dx)
        let maxDistance = dpadRadius

        if distance > 10 { // Dead zone
            inputState.horizontalDirection = (dx / maxDistance).clamped(to: -1...1)
        } else {
            inputState.horizontalDirection = 0
        }

        // Move indicator
        if let indicator = dpadNode.childNode(withName: "indicator") {
            let clampedX = (dx).clamped(to: -maxDistance...maxDistance)
            indicator.position = CGPoint(x: clampedX, y: 0)
        }
    }

    func postUpdate() {
        previousJumpPressed = inputState.jumpPressed
        inputState.jumpJustPressed = false
    }
}
