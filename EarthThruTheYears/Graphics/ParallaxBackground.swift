import SpriteKit

class ParallaxBackground {
    private var layers: [(node: SKNode, speed: CGFloat)] = []
    private let sceneSize: CGSize

    init(scene: SKScene, era: Era) {
        self.sceneSize = scene.size
        let colors = ColorPalette.colors(for: era)
        setupLayers(scene: scene, colors: colors, era: era)
    }

    private func setupLayers(scene: SKScene, colors: EraColors, era: Era) {
        // Layer 1: Sky gradient (furthest back)
        let sky = createSkyLayer(colors: colors)
        sky.zPosition = Constants.ZPosition.background
        scene.addChild(sky)
        layers.append((sky, 0.0)) // Sky doesn't scroll

        // Layer 2: Distant mountains/hills
        let mountains = createMountainLayer(colors: colors, era: era)
        mountains.zPosition = Constants.ZPosition.backgroundLayer1
        scene.addChild(mountains)
        layers.append((mountains, 0.1))

        // Layer 3: Mid-distance vegetation
        let vegetation = createVegetationLayer(colors: colors, era: era)
        vegetation.zPosition = Constants.ZPosition.backgroundLayer2
        scene.addChild(vegetation)
        layers.append((vegetation, 0.3))

        // Layer 4: Near clouds/atmosphere
        let atmosphere = createAtmosphereLayer(colors: colors, era: era)
        atmosphere.zPosition = Constants.ZPosition.backgroundLayer3
        scene.addChild(atmosphere)
        layers.append((atmosphere, 0.5))
    }

    private func createSkyLayer(colors: EraColors) -> SKNode {
        let node = SKNode()
        let skyWidth = sceneSize.width * 20 // Wide enough for longest levels
        // Top half
        let top = SKSpriteNode(color: colors.skyTop, size: CGSize(width: skyWidth, height: sceneSize.height / 2))
        top.position = CGPoint(x: skyWidth / 2, y: sceneSize.height * 0.75)
        node.addChild(top)
        // Bottom half
        let bottom = SKSpriteNode(color: colors.skyBottom, size: CGSize(width: skyWidth, height: sceneSize.height / 2))
        bottom.position = CGPoint(x: skyWidth / 2, y: sceneSize.height * 0.25)
        node.addChild(bottom)
        return node
    }

    private func createMountainLayer(colors: EraColors, era: Era) -> SKNode {
        let node = SKNode()
        let mountainColor = colors.groundTop.withAlphaComponent(0.5)

        for i in 0..<8 {
            let width = CGFloat.random(in: 200...400)
            let height = CGFloat.random(in: 120...250)
            let mountain = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: height / 3)
            mountain.fillColor = mountainColor
            mountain.strokeColor = .clear
            mountain.position = CGPoint(x: CGFloat(i) * 350, y: height / 2 + 50)
            node.addChild(mountain)
        }

        return node
    }

    private func createVegetationLayer(colors: EraColors, era: Era) -> SKNode {
        let node = SKNode()
        let vegColor = colors.treeLeaves.withAlphaComponent(0.4)

        for i in 0..<12 {
            let bush = SKShapeNode(circleOfRadius: CGFloat.random(in: 20...50))
            bush.fillColor = vegColor
            bush.strokeColor = .clear
            bush.position = CGPoint(x: CGFloat(i) * 220 + CGFloat.random(in: -30...30),
                                    y: CGFloat.random(in: 80...160))
            node.addChild(bush)
        }

        return node
    }

    private func createAtmosphereLayer(colors: EraColors, era: Era) -> SKNode {
        let node = SKNode()

        switch era {
        case .triassic:
            // Dust particles
            for i in 0..<6 {
                let dust = SKShapeNode(circleOfRadius: CGFloat.random(in: 30...60))
                dust.fillColor = SKColor(red: 0.9, green: 0.8, blue: 0.6, alpha: 0.15)
                dust.strokeColor = .clear
                dust.position = CGPoint(x: CGFloat(i) * 300 + CGFloat.random(in: 0...100),
                                        y: CGFloat.random(in: 300...600))
                node.addChild(dust)
            }
        case .jurassic:
            // Mist
            for i in 0..<5 {
                let mist = SKShapeNode(ellipseOf: CGSize(width: CGFloat.random(in: 150...300),
                                                           height: CGFloat.random(in: 30...60)))
                mist.fillColor = SKColor(white: 1, alpha: 0.08)
                mist.strokeColor = .clear
                mist.position = CGPoint(x: CGFloat(i) * 350, y: CGFloat.random(in: 200...500))
                node.addChild(mist)
            }
        case .cretaceous:
            // Volcanic smoke
            for i in 0..<7 {
                let smoke = SKShapeNode(circleOfRadius: CGFloat.random(in: 40...80))
                smoke.fillColor = SKColor(red: 0.3, green: 0.2, blue: 0.15, alpha: 0.2)
                smoke.strokeColor = .clear
                smoke.position = CGPoint(x: CGFloat(i) * 280 + CGFloat.random(in: 0...80),
                                         y: CGFloat.random(in: 350...650))
                node.addChild(smoke)
            }
        }

        return node
    }

    func update(cameraX: CGFloat) {
        for (layer, speed) in layers {
            layer.position.x = -cameraX * speed
        }
    }
}
