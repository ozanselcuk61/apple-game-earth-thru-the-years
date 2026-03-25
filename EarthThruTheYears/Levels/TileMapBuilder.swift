import SpriteKit
import GameplayKit

class TileMapBuilder {

    private let tileSize: CGFloat
    private let sceneSize: CGSize
    private let random: GKMersenneTwisterRandomSource

    init(seed: UInt64, sceneSize: CGSize) {
        self.tileSize = Constants.tileSize
        self.sceneSize = sceneSize
        self.random = GKMersenneTwisterRandomSource(seed: seed)
    }

    // MARK: - Ground

    func buildGround(levelWidth: CGFloat, era: Era) -> [SKNode] {
        var nodes: [SKNode] = []
        let colors = ColorPalette.colors(for: era)
        let groundY = Constants.groundHeight

        var x: CGFloat = 0
        while x < levelWidth {
            // Decide if there's a gap
            let hasGap = x > sceneSize.width && random.nextInt(upperBound: 10) < 2
            let segmentWidth: CGFloat

            if hasGap {
                // Gap
                let gapWidth = CGFloat(random.nextInt(upperBound: 3) + 2) * tileSize
                x += gapWidth

                // Add boundary for death pit
                let boundary = SKNode()
                boundary.position = CGPoint(x: x - gapWidth / 2, y: -50)
                let boundaryBody = SKPhysicsBody(rectangleOf: CGSize(width: gapWidth, height: 50))
                boundaryBody.categoryBitMask = PhysicsCategory.boundary
                boundaryBody.contactTestBitMask = PhysicsCategory.player
                boundaryBody.collisionBitMask = PhysicsCategory.none
                boundaryBody.isDynamic = false
                boundary.physicsBody = boundaryBody
                boundary.name = "deathPit"
                nodes.append(boundary)

                continue
            }

            segmentWidth = CGFloat(random.nextInt(upperBound: 6) + 4) * tileSize
            let height = groundY // Flat ground to prevent edge-catching

            let ground = SKSpriteNode(color: colors.groundTop, size: CGSize(width: segmentWidth, height: height))
            ground.position = CGPoint(x: x + segmentWidth / 2, y: height / 2)
            ground.zPosition = Constants.ZPosition.ground
            ground.name = "ground"

            let body = SKPhysicsBody(rectangleOf: ground.size)
            body.categoryBitMask = PhysicsCategory.ground
            body.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy
            body.contactTestBitMask = PhysicsCategory.player
            body.isDynamic = false
            body.friction = 0.3
            ground.physicsBody = body

            nodes.append(ground)

            // Add dirt layer below
            let dirt = SKSpriteNode(color: colors.groundBottom,
                                    size: CGSize(width: segmentWidth, height: 30))
            dirt.position = CGPoint(x: x + segmentWidth / 2, y: height / 2 - (height / 2 + 15))
            dirt.zPosition = Constants.ZPosition.ground - 1
            nodes.append(dirt)

            x += segmentWidth
        }

        // Ensure the start area has solid ground
        let startGround = SKSpriteNode(color: colors.groundTop,
                                        size: CGSize(width: sceneSize.width, height: groundY))
        startGround.position = CGPoint(x: sceneSize.width / 2, y: groundY / 2)
        startGround.zPosition = Constants.ZPosition.ground + 0.1
        startGround.name = "ground"
        let startBody = SKPhysicsBody(rectangleOf: startGround.size)
        startBody.categoryBitMask = PhysicsCategory.ground
        startBody.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy
        startBody.contactTestBitMask = PhysicsCategory.player
        startBody.isDynamic = false
        startBody.friction = 0.7
        startGround.physicsBody = startBody
        nodes.insert(startGround, at: 0)

        return nodes
    }

    // MARK: - Platforms

    func buildPlatforms(count: Int, levelWidth: CGFloat, era: Era) -> [SKNode] {
        var platforms: [SKNode] = []
        let colors = ColorPalette.colors(for: era)
        let spacing = levelWidth / CGFloat(count + 1)

        for i in 0..<count {
            let width = CGFloat(random.nextInt(upperBound: 4) + 3) * tileSize
            let x = spacing * CGFloat(i + 1) + CGFloat(random.nextInt(upperBound: 80) - 40)
            let y = Constants.groundHeight + CGFloat(random.nextInt(upperBound: 150) + 80)

            let platform = SKSpriteNode(color: colors.platform, size: CGSize(width: width, height: 18))
            platform.position = CGPoint(x: x, y: y)
            platform.zPosition = Constants.ZPosition.ground
            platform.name = "platform"

            let body = SKPhysicsBody(rectangleOf: platform.size)
            body.categoryBitMask = PhysicsCategory.platform
            body.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy
            body.contactTestBitMask = PhysicsCategory.player
            body.isDynamic = false
            body.friction = 0.3
            platform.physicsBody = body

            platforms.append(platform)
        }

        return platforms
    }

    // MARK: - Decorations (Trees)

    func buildDecorations(levelWidth: CGFloat, era: Era) -> [SKNode] {
        var decorations: [SKNode] = []
        let treeSpacing = CGFloat(random.nextInt(upperBound: 150) + 200)
        var x: CGFloat = 150

        while x < levelWidth - 100 {
            let tree = NodeFactory.makeTree(era: era)
            tree.position = CGPoint(x: x, y: Constants.groundHeight)
            tree.zPosition = Constants.ZPosition.decoration
            decorations.append(tree)
            x += treeSpacing + CGFloat(random.nextInt(upperBound: 100))
        }

        return decorations
    }
}
