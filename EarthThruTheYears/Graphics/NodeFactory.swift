import SpriteKit

enum NodeFactory {

    // MARK: - Player Character

    static func makePlayer(type: CharacterType) -> SKNode {
        let root = SKNode()
        root.name = "player"

        let sprite = SKSpriteNode(imageNamed: type == .boy ? "boy_idle" : "girl_idle")
        sprite.setScale(2.0)
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0) // Bottom-center anchor
        sprite.position = CGPoint(x: 0, y: 0)
        root.addChild(sprite)

        return root
    }

    // MARK: - Robot Companion

    static func makeRobot() -> SKNode {
        let root = SKNode()
        root.name = "robot"

        let sprite = SKSpriteNode(imageNamed: "robot")
        sprite.setScale(2.0)
        root.addChild(sprite)

        return root
    }

    // MARK: - Dinosaurs

    static func makeDinosaur(type: DinosaurType) -> SKNode {
        let root = SKNode()
        root.name = "dinosaur"

        let imageName: String
        switch type {
        case .coelophysis:
            imageName = "dino_coelophysis"
        case .smallRaptor:
            imageName = "dino_raptor"
        case .tRex:
            imageName = "dino_trex"
        case .triceratops:
            imageName = "dino_triceratops"
        case .stegosaurus:
            imageName = "dino_stegosaurus"
        case .largeSauropod:
            imageName = "dino_sauropod"
        case .pterodactyl:
            // No specific pixel art for pterodactyl; reuse raptor
            imageName = "dino_raptor"
        case .plateosaurus:
            // No specific pixel art for plateosaurus; reuse sauropod
            imageName = "dino_sauropod"
        }

        let sprite = SKSpriteNode(imageNamed: imageName)
        sprite.setScale(2.0)
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0) // Bottom-center so dino sits on ground
        root.addChild(sprite)

        return root
    }

    // MARK: - Coin

    static func makeCoin() -> SKNode {
        let container = SKNode()
        container.name = "coin"

        let sprite = SKSpriteNode(imageNamed: "coin")
        sprite.setScale(2.0)
        container.addChild(sprite)

        // Subtle float animation
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 4, duration: 0.8),
            SKAction.moveBy(x: 0, y: -4, duration: 0.8)
        ])
        container.run(SKAction.repeatForever(float))

        return container
    }

    // MARK: - End Flag

    static func makeEndFlag() -> SKNode {
        let root = SKNode()
        root.name = "endFlag"

        let sprite = SKSpriteNode(imageNamed: "end_flag")
        sprite.setScale(2.0)
        sprite.position = CGPoint(x: 0, y: 60)
        root.addChild(sprite)

        return root
    }

    // MARK: - Trees

    static func makeTree(era: Era) -> SKNode {
        let root = SKNode()

        let imageName: String
        switch era {
        case .triassic:
            imageName = "tree_triassic"
        case .jurassic:
            imageName = "tree_jurassic"
        case .cretaceous:
            imageName = "tree_cretaceous"
        }

        let sprite = SKSpriteNode(imageNamed: imageName)
        sprite.setScale(2.0)
        sprite.position = CGPoint(x: 0, y: sprite.size.height)
        root.addChild(sprite)

        return root
    }

    // MARK: - UI Buttons

    static func makeButton(text: String, size: CGSize = CGSize(width: 260, height: 55)) -> SKNode {
        let root = SKNode()
        root.name = text

        let bg = SKShapeNode(rectOf: size, cornerRadius: 12)
        bg.fillColor = ColorPalette.buttonColor
        bg.strokeColor = ColorPalette.buttonHighlight
        bg.lineWidth = 2
        bg.name = "\(text)_bg"
        root.addChild(bg)

        let label = SKLabelNode(text: text)
        label.fontName = Constants.fontName
        label.fontSize = 22
        label.fontColor = ColorPalette.textColor
        label.verticalAlignmentMode = .center
        label.name = "\(text)_label"
        root.addChild(label)

        return root
    }

    // MARK: - Power-ups

    static func makePowerUp(type: PowerUpType) -> SKNode {
        let root = SKNode()
        root.name = "powerUp"

        let imageName: String
        switch type {
        case .extraLife:
            imageName = "powerup_life"
        case .shield:
            imageName = "powerup_shield"
        case .speedBoost:
            imageName = "heart"
        }

        let sprite = SKSpriteNode(imageNamed: imageName)
        sprite.setScale(2.0)
        root.addChild(sprite)

        // Bounce animation
        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 8, duration: 0.6),
            SKAction.moveBy(x: 0, y: -8, duration: 0.6)
        ])
        root.run(SKAction.repeatForever(bounce))

        return root
    }
}
