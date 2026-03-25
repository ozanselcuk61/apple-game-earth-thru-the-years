import SpriteKit

enum PowerUpType {
    case extraLife
    case shield
    case speedBoost
}

class PowerUp: SKNode {

    let type: PowerUpType
    var isCollected = false

    init(type: PowerUpType) {
        self.type = type
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        name = "powerUp"
        zPosition = Constants.ZPosition.powerUp

        let visual = NodeFactory.makePowerUp(type: type)
        addChild(visual)

        let body = SKPhysicsBody(rectangleOf: CGSize(width: 28, height: 28))
        body.categoryBitMask = PhysicsCategory.powerUp
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        body.affectedByGravity = false
        body.isDynamic = false
        physicsBody = body
    }

    func collect(player: PlayerCharacter) {
        guard !isCollected else { return }
        isCollected = true

        switch type {
        case .extraLife:
            player.health.addLife()
            player.syncLivesToManager()
        case .shield:
            // Grant temporary invincibility
            break
        case .speedBoost:
            // Speed boost handled in GameScene
            break
        }

        physicsBody?.categoryBitMask = PhysicsCategory.none
        let anim = SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 50, duration: 0.4),
                SKAction.fadeOut(withDuration: 0.4),
                SKAction.scale(to: 2.0, duration: 0.4)
            ]),
            SKAction.removeFromParent()
        ])
        run(anim)
    }
}
