import SpriteKit

enum DinosaurType: String {
    // Triassic
    case coelophysis
    case plateosaurus
    // Jurassic
    case smallRaptor
    case largeSauropod
    case stegosaurus
    // Cretaceous
    case tRex
    case triceratops
    case pterodactyl

    var speed: CGFloat {
        switch self {
        case .coelophysis: return 80
        case .plateosaurus: return 50
        case .smallRaptor: return 120
        case .largeSauropod: return 30
        case .stegosaurus: return 40
        case .tRex: return 70
        case .triceratops: return 60
        case .pterodactyl: return 100
        }
    }

    var bodySize: CGSize {
        switch self {
        case .coelophysis: return CGSize(width: 35, height: 30)
        case .plateosaurus: return CGSize(width: 55, height: 65)
        case .smallRaptor: return CGSize(width: 40, height: 28)
        case .largeSauropod: return CGSize(width: 80, height: 120)
        case .stegosaurus: return CGSize(width: 65, height: 45)
        case .tRex: return CGSize(width: 70, height: 70)
        case .triceratops: return CGSize(width: 60, height: 45)
        case .pterodactyl: return CGSize(width: 50, height: 20)
        }
    }

    var isFlying: Bool {
        return self == .pterodactyl
    }

    var points: Int {
        switch self {
        case .coelophysis: return 5
        case .plateosaurus: return 10
        case .smallRaptor: return 8
        case .largeSauropod: return 15
        case .stegosaurus: return 12
        case .tRex: return 25
        case .triceratops: return 15
        case .pterodactyl: return 10
        }
    }
}

class Dinosaur: SKNode {

    let type: DinosaurType
    private var patrolMinX: CGFloat = 0
    private var patrolMaxX: CGFloat = 0
    private var movingRight = true
    private(set) var isAlive = true

    init(type: DinosaurType, patrolRange: CGFloat = 200) {
        self.type = type
        super.init()
        setup(patrolRange: patrolRange)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(patrolRange: CGFloat) {
        name = "dinosaur"
        zPosition = Constants.ZPosition.enemy

        let visual = NodeFactory.makeDinosaur(type: type)
        visual.name = "visual"
        addChild(visual)

        // Physics
        let bodyCenter = CGPoint(x: 0, y: type.bodySize.height / 2)
        let body = SKPhysicsBody(rectangleOf: type.bodySize, center: bodyCenter)
        body.categoryBitMask = PhysicsCategory.enemy
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.platform
        body.allowsRotation = false
        body.affectedByGravity = !type.isFlying
        body.friction = 1.0
        body.mass = 2.0
        physicsBody = body

        // Store initial patrol bounds (will be set properly by LevelBuilder)
        self.patrolMinX = -patrolRange / 2
        self.patrolMaxX = patrolRange / 2
    }

    func setPatrolBounds(minX: CGFloat, maxX: CGFloat) {
        self.patrolMinX = minX
        self.patrolMaxX = maxX
    }

    func update(deltaTime: TimeInterval) {
        guard isAlive else { return }
        patrol()
    }

    private func patrol() {
        guard let body = physicsBody else { return }

        if position.x <= patrolMinX {
            movingRight = true
        } else if position.x >= patrolMaxX {
            movingRight = false
        }

        let direction: CGFloat = movingRight ? 1 : -1
        body.velocity.dx = direction * type.speed

        // Flip visual
        childNode(withName: "visual")?.xScale = movingRight ? 1 : -1
    }

    func defeat() {
        guard isAlive else { return }
        isAlive = false
        physicsBody?.categoryBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.none
        physicsBody?.collisionBitMask = PhysicsCategory.none

        let anim = SKAction.sequence([
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.scale(to: 0.5, duration: 0.3),
                SKAction.moveBy(x: 0, y: 20, duration: 0.3)
            ]),
            SKAction.removeFromParent()
        ])
        run(anim)
    }

    func isStompedBy(player: SKNode) -> Bool {
        // Player must be above the dinosaur and moving downward
        let playerBottom = player.position.y
        let dinoTop = position.y + type.bodySize.height
        let playerVelocity = player.physicsBody?.velocity.dy ?? 0

        return playerBottom > dinoTop - 20 && playerVelocity < -50
    }
}
