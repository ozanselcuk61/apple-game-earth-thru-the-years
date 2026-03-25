import SpriteKit

class Coin: SKNode {

    var isCollected = false

    override init() {
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        name = "coin"
        zPosition = Constants.ZPosition.coin

        let visual = NodeFactory.makeCoin()
        addChild(visual)

        // Physics
        let body = SKPhysicsBody(circleOfRadius: Constants.coinSize / 2)
        body.categoryBitMask = PhysicsCategory.coin
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        body.affectedByGravity = false
        body.isDynamic = false
        physicsBody = body
    }

    func collect() {
        guard !isCollected else { return }
        isCollected = true

        physicsBody?.categoryBitMask = PhysicsCategory.none

        let anim = SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 40, duration: 0.3),
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.scale(to: 1.5, duration: 0.3)
            ]),
            SKAction.removeFromParent()
        ])
        run(anim)
    }
}
