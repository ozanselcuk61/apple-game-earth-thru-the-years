import SpriteKit

class LevelBuilder {

    private let levelData: LevelData
    private let scene: SKScene
    private let tileMapBuilder: TileMapBuilder

    init(levelData: LevelData, scene: SKScene) {
        self.levelData = levelData
        self.scene = scene

        // Create deterministic seed from era + sublevel
        let seed = UInt64(levelData.era.rawValue * 100 + levelData.subLevel)
        self.tileMapBuilder = TileMapBuilder(seed: seed, sceneSize: scene.size)
    }

    func build() -> LevelComponents {
        let levelWidth = levelData.totalWidth

        // Ground
        let groundNodes = tileMapBuilder.buildGround(levelWidth: levelWidth, era: levelData.era)
        groundNodes.forEach { scene.addChild($0) }

        // Platforms
        let platformNodes = tileMapBuilder.buildPlatforms(count: levelData.platformCount,
                                                           levelWidth: levelWidth,
                                                           era: levelData.era)
        platformNodes.forEach { scene.addChild($0) }

        // Decorations
        let decorations = tileMapBuilder.buildDecorations(levelWidth: levelWidth, era: levelData.era)
        decorations.forEach { scene.addChild($0) }

        // Coins
        let coins = placeCoins(levelWidth: levelWidth, platforms: platformNodes)
        coins.forEach { scene.addChild($0) }

        // Dinosaurs
        let dinosaurs = DinosaurFactory.createDinosaurs(
            count: levelData.enemyCount,
            era: levelData.era,
            subLevel: levelData.subLevel,
            levelWidth: levelWidth
        )
        dinosaurs.forEach { scene.addChild($0) }

        // Power-ups
        let powerUps = placePowerUps(levelWidth: levelWidth, platforms: platformNodes)
        powerUps.forEach { scene.addChild($0) }

        // End flag
        let endFlag = NodeFactory.makeEndFlag()
        endFlag.position = CGPoint(x: levelWidth - 100, y: Constants.groundHeight)
        endFlag.zPosition = Constants.ZPosition.decoration

        let flagBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 120),
                                      center: CGPoint(x: 0, y: 60))
        flagBody.categoryBitMask = PhysicsCategory.endFlag
        flagBody.contactTestBitMask = PhysicsCategory.player
        flagBody.collisionBitMask = PhysicsCategory.none
        flagBody.isDynamic = false
        endFlag.physicsBody = flagBody
        scene.addChild(endFlag)

        // Bottom boundary (death)
        let bottomBoundary = SKNode()
        bottomBoundary.position = CGPoint(x: levelWidth / 2, y: -100)
        let bottomBody = SKPhysicsBody(rectangleOf: CGSize(width: levelWidth + 200, height: 50))
        bottomBody.categoryBitMask = PhysicsCategory.boundary
        bottomBody.contactTestBitMask = PhysicsCategory.player
        bottomBody.collisionBitMask = PhysicsCategory.none
        bottomBody.isDynamic = false
        bottomBoundary.physicsBody = bottomBody
        bottomBoundary.name = "bottomBoundary"
        scene.addChild(bottomBoundary)

        return LevelComponents(
            coins: coins,
            dinosaurs: dinosaurs,
            powerUps: powerUps,
            levelWidth: levelWidth
        )
    }

    // MARK: - Coin Placement

    private func placeCoins(levelWidth: CGFloat, platforms: [SKNode]) -> [Coin] {
        var coins: [Coin] = []
        let coinSpacing = levelWidth / CGFloat(levelData.totalCoins + 1)

        for i in 0..<levelData.totalCoins {
            let coin = Coin()
            let baseX = coinSpacing * CGFloat(i + 1) + CGFloat.random(in: -30...30)
            let x = baseX.clamped(to: 100...(levelWidth - 200))

            // Place coins at reachable heights - some on ground, some in air
            let coinY: CGFloat
            if let nearPlatform = platforms.first(where: { abs($0.position.x - x) < 100 }) {
                coinY = nearPlatform.position.y + 30
            } else {
                // Mix: 60% ground level, 40% jump level
                let isGroundCoin = i % 5 < 3
                if isGroundCoin {
                    coinY = Constants.groundHeight + CGFloat.random(in: 20...40)
                } else {
                    coinY = Constants.groundHeight + CGFloat.random(in: 50...90)
                }
            }

            coin.position = CGPoint(x: x, y: coinY)
            coins.append(coin)
        }

        return coins
    }

    // MARK: - Power-Up Placement

    private func placePowerUps(levelWidth: CGFloat, platforms: [SKNode]) -> [PowerUp] {
        var powerUps: [PowerUp] = []
        let spacing = levelWidth / CGFloat(levelData.powerUpCount + 1)

        for i in 0..<levelData.powerUpCount {
            let type: PowerUpType
            if i == 0 && levelData.subLevel >= 3 {
                type = .extraLife
            } else {
                type = [PowerUpType.shield, .speedBoost].randomElement() ?? .shield
            }

            let powerUp = PowerUp(type: type)
            let x = spacing * CGFloat(i + 1) + CGFloat.random(in: -50...50)

            // Place on platforms if possible
            let y: CGFloat
            if let platform = platforms.filter({ abs($0.position.x - x) < 80 }).first {
                y = platform.position.y + 40
            } else {
                y = Constants.groundHeight + CGFloat.random(in: 80...150)
            }

            powerUp.position = CGPoint(x: x.clamped(to: 200...(levelWidth - 200)), y: y)
            powerUps.append(powerUp)
        }

        return powerUps
    }
}

struct LevelComponents {
    let coins: [Coin]
    let dinosaurs: [Dinosaur]
    let powerUps: [PowerUp]
    let levelWidth: CGFloat
}
