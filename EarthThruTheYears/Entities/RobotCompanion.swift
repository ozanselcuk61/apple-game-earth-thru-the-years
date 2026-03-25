import SpriteKit

class RobotCompanion: SKNode {

    private let followOffset = CGPoint(x: -50, y: 10)
    private let followSpeed: CGFloat = 0.08
    private weak var target: SKNode?

    init(target: SKNode) {
        self.target = target
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        name = "robotCompanion"
        zPosition = Constants.ZPosition.robot

        let visual = NodeFactory.makeRobot()
        visual.setScale(0.7) // Slightly smaller than player
        addChild(visual)

        // No physics collisions - the robot is just visual
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 16, height: 20), center: CGPoint(x: 0, y: 10))
        body.categoryBitMask = PhysicsCategory.robot
        body.contactTestBitMask = PhysicsCategory.none
        body.collisionBitMask = PhysicsCategory.none
        body.affectedByGravity = false
        body.allowsRotation = false
        physicsBody = body
    }

    func update(deltaTime: TimeInterval) {
        guard let target = target else { return }

        let targetX = target.position.x + followOffset.x
        let targetY = target.position.y + followOffset.y

        let newX = CGFloat.lerp(from: position.x, to: targetX, t: followSpeed)
        let newY = CGFloat.lerp(from: position.y, to: targetY, t: followSpeed)

        position = CGPoint(x: newX, y: newY)

        // Face same direction as player
        if let playerScale = target.childNode(withName: "visual")?.xScale {
            children.first?.xScale = playerScale > 0 ? 1 : -1
            // Adjust follow offset based on direction
        }

        // Slight bobbing animation
        let bob = sin(CACurrentMediaTime() * 3) * 3
        position.y += CGFloat(bob)
    }
}
