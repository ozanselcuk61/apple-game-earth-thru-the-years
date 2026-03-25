import SpriteKit

class PlayerCharacter: SKNode {

    let characterType: CharacterType
    let health: HealthComponent
    private(set) var isGrounded = false
    private var walkAnimTimer: TimeInterval = 0

    init(type: CharacterType) {
        self.characterType = type
        self.health = HealthComponent(lives: GameManager.shared.lives)
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        name = "playerCharacter"
        zPosition = Constants.ZPosition.player

        // Add visual node
        let visual = NodeFactory.makePlayer(type: characterType)
        visual.name = "visual"
        addChild(visual)

        // Physics body - circle at feet to slide over ground edges
        let bodyHeight: CGFloat = 60
        let bodyWidth: CGFloat = 30
        let circleRadius: CGFloat = bodyWidth / 2
        let body = SKPhysicsBody(circleOfRadius: circleRadius, center: CGPoint(x: 0, y: circleRadius))
        body.categoryBitMask = PhysicsCategory.player
        body.contactTestBitMask = PhysicsCategory.coin | PhysicsCategory.enemy | PhysicsCategory.powerUp |
                                   PhysicsCategory.boundary | PhysicsCategory.endFlag
        body.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.platform
        body.allowsRotation = false
        body.friction = 0.0
        body.restitution = 0
        body.mass = 1.0
        physicsBody = body
    }

    // MARK: - Movement

    func applyMovement(direction: CGFloat) {
        guard let body = physicsBody else { return }
        let targetVelocityX = direction * Constants.playerMoveSpeed
        body.velocity.dx = targetVelocityX

        // Flip sprite based on direction
        if direction < -0.1 {
            childNode(withName: "visual")?.xScale = -1
        } else if direction > 0.1 {
            childNode(withName: "visual")?.xScale = 1
        }
    }

    func jump() {
        guard isGrounded, let body = physicsBody else { return }
        body.velocity.dy = 0 // Reset before impulse
        body.applyImpulse(CGVector(dx: 0, dy: Constants.playerJumpImpulse * body.mass))
        isGrounded = false
        AudioManager.shared.playJumpSound(on: self)
    }

    func setGrounded(_ grounded: Bool) {
        isGrounded = grounded
    }

    // MARK: - Damage

    func takeDamage() -> Bool {
        let damaged = health.takeDamage()
        if damaged {
            AudioManager.shared.playHurtSound(on: self)
            // Knockback
            physicsBody?.velocity = CGVector(dx: -200, dy: 300)
        }
        return damaged
    }

    // MARK: - Update

    func update(deltaTime: TimeInterval) {
        health.update(deltaTime: deltaTime)

        if let visual = childNode(withName: "visual") {
            health.applyInvincibilityVisual(to: visual)
        }

        // Clamp vertical velocity
        if let body = physicsBody {
            body.velocity.dy = body.velocity.dy.clamped(to: -Constants.maxPlayerVelocityY...Constants.maxPlayerVelocityY)

            // Ground detection: if vertical velocity is near zero, consider grounded
            if abs(body.velocity.dy) < 8.0 {
                isGrounded = true
            }
        }

        // Simple walk animation
        animateWalk(deltaTime: deltaTime)
    }

    private func animateWalk(deltaTime: TimeInterval) {
        guard let visual = childNode(withName: "visual") else { return }
        let isMoving = abs(physicsBody?.velocity.dx ?? 0) > 10

        if isMoving && isGrounded {
            walkAnimTimer += deltaTime
            let offset = sin(walkAnimTimer * 12) * 4
            visual.childNode(withName: "leftLeg")?.position.y = -8 + CGFloat(offset)
            visual.childNode(withName: "rightLeg")?.position.y = -8 - CGFloat(offset)
        } else {
            visual.childNode(withName: "leftLeg")?.position.y = -8
            visual.childNode(withName: "rightLeg")?.position.y = -8
        }
    }

    func syncLivesToManager() {
        GameManager.shared.lives = health.lives
    }
}
