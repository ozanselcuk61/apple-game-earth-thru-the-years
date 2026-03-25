import SpriteKit

enum NodeFactory {

    // MARK: - Player Character

    static func makePlayer(type: CharacterType) -> SKNode {
        let root = SKNode()
        root.name = "player"

        let bodyColor = type == .boy ? ColorPalette.boyColor : ColorPalette.girlColor

        // Body
        let body = SKSpriteNode(color: bodyColor, size: CGSize(width: 28, height: 32))
        body.position = CGPoint(x: 0, y: 16)
        body.name = "body"
        root.addChild(body)

        // Head
        let head = SKShapeNode(circleOfRadius: 14)
        head.fillColor = ColorPalette.skinColor
        head.strokeColor = .clear
        head.position = CGPoint(x: 0, y: 42)
        head.name = "head"
        root.addChild(head)

        // Eyes
        let leftEye = SKShapeNode(circleOfRadius: 3)
        leftEye.fillColor = .black
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -5, y: 44)
        root.addChild(leftEye)

        let rightEye = SKShapeNode(circleOfRadius: 3)
        rightEye.fillColor = .black
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: 5, y: 44)
        root.addChild(rightEye)

        // Legs
        let leftLeg = SKSpriteNode(color: bodyColor.withAlphaComponent(0.8), size: CGSize(width: 10, height: 16))
        leftLeg.position = CGPoint(x: -7, y: -8)
        leftLeg.name = "leftLeg"
        root.addChild(leftLeg)

        let rightLeg = SKSpriteNode(color: bodyColor.withAlphaComponent(0.8), size: CGSize(width: 10, height: 16))
        rightLeg.position = CGPoint(x: 7, y: -8)
        rightLeg.name = "rightLeg"
        root.addChild(rightLeg)

        // Hair indicator for girl
        if type == .girl {
            let hair = SKShapeNode(circleOfRadius: 16)
            hair.fillColor = SKColor(red: 0.6, green: 0.3, blue: 0.1, alpha: 1)
            hair.strokeColor = .clear
            hair.position = CGPoint(x: 0, y: 46)
            hair.zPosition = -1
            root.addChild(hair)

            let ribbon = SKSpriteNode(color: .magenta, size: CGSize(width: 8, height: 8))
            ribbon.position = CGPoint(x: 10, y: 54)
            root.addChild(ribbon)
        } else {
            let hair = SKSpriteNode(color: SKColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1),
                                     size: CGSize(width: 26, height: 10))
            hair.position = CGPoint(x: 0, y: 52)
            root.addChild(hair)
        }

        return root
    }

    // MARK: - Robot Companion

    static func makeRobot() -> SKNode {
        let root = SKNode()
        root.name = "robot"

        // Body
        let body = SKSpriteNode(color: ColorPalette.robotColor, size: CGSize(width: 22, height: 26))
        body.position = CGPoint(x: 0, y: 13)
        root.addChild(body)

        // Head
        let head = SKSpriteNode(color: ColorPalette.robotColor, size: CGSize(width: 18, height: 16))
        head.position = CGPoint(x: 0, y: 34)
        root.addChild(head)

        // Antenna
        let antenna = SKSpriteNode(color: ColorPalette.robotAccent, size: CGSize(width: 3, height: 10))
        antenna.position = CGPoint(x: 0, y: 47)
        root.addChild(antenna)

        let antennaBall = SKShapeNode(circleOfRadius: 4)
        antennaBall.fillColor = ColorPalette.robotAccent
        antennaBall.strokeColor = .clear
        antennaBall.position = CGPoint(x: 0, y: 53)
        root.addChild(antennaBall)

        // Glow effect on antenna
        let glow = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 0.5),
            SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        ])
        antennaBall.run(SKAction.repeatForever(glow))

        // Eyes
        let leftEye = SKShapeNode(circleOfRadius: 3)
        leftEye.fillColor = ColorPalette.robotAccent
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -5, y: 36)
        root.addChild(leftEye)

        let rightEye = SKShapeNode(circleOfRadius: 3)
        rightEye.fillColor = ColorPalette.robotAccent
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: 5, y: 36)
        root.addChild(rightEye)

        // Legs
        let leftLeg = SKSpriteNode(color: ColorPalette.robotColor.withAlphaComponent(0.8),
                                    size: CGSize(width: 8, height: 10))
        leftLeg.position = CGPoint(x: -5, y: -5)
        root.addChild(leftLeg)

        let rightLeg = SKSpriteNode(color: ColorPalette.robotColor.withAlphaComponent(0.8),
                                     size: CGSize(width: 8, height: 10))
        rightLeg.position = CGPoint(x: 5, y: -5)
        root.addChild(rightLeg)

        return root
    }

    // MARK: - Dinosaurs

    static func makeDinosaur(type: DinosaurType) -> SKNode {
        let root = SKNode()
        root.name = "dinosaur"

        switch type {
        case .smallRaptor:
            makeSmallRaptor(root: root)
        case .largeSauropod:
            makeLargeSauropod(root: root)
        case .triceratops:
            makeTriceratops(root: root)
        case .pterodactyl:
            makePterodactyl(root: root)
        case .tRex:
            makeTRex(root: root)
        case .stegosaurus:
            makeStegosaurus(root: root)
        case .coelophysis:
            makeCoelophysis(root: root)
        case .plateosaurus:
            makePlateosaurus(root: root)
        }

        return root
    }

    private static func makeSmallRaptor(root: SKNode) {
        let body = SKSpriteNode(color: SKColor(red: 0.45, green: 0.55, blue: 0.30, alpha: 1),
                                 size: CGSize(width: 40, height: 24))
        body.position = CGPoint(x: 0, y: 12)
        root.addChild(body)

        let head = SKShapeNode(ellipseOf: CGSize(width: 20, height: 16))
        head.fillColor = SKColor(red: 0.50, green: 0.60, blue: 0.35, alpha: 1)
        head.strokeColor = .clear
        head.position = CGPoint(x: 22, y: 18)
        root.addChild(head)

        let eye = SKShapeNode(circleOfRadius: 2)
        eye.fillColor = .red
        eye.strokeColor = .clear
        eye.position = CGPoint(x: 28, y: 20)
        root.addChild(eye)

        let tail = SKSpriteNode(color: SKColor(red: 0.40, green: 0.50, blue: 0.25, alpha: 1),
                                 size: CGSize(width: 25, height: 8))
        tail.position = CGPoint(x: -28, y: 14)
        tail.zRotation = 0.2
        root.addChild(tail)
    }

    private static func makeLargeSauropod(root: SKNode) {
        let body = SKSpriteNode(color: SKColor(red: 0.40, green: 0.55, blue: 0.40, alpha: 1),
                                 size: CGSize(width: 80, height: 50))
        body.position = CGPoint(x: 0, y: 40)
        root.addChild(body)

        let neck = SKSpriteNode(color: SKColor(red: 0.45, green: 0.60, blue: 0.45, alpha: 1),
                                 size: CGSize(width: 15, height: 60))
        neck.position = CGPoint(x: 35, y: 80)
        neck.zRotation = 0.3
        root.addChild(neck)

        let head = SKShapeNode(ellipseOf: CGSize(width: 22, height: 16))
        head.fillColor = SKColor(red: 0.45, green: 0.60, blue: 0.45, alpha: 1)
        head.strokeColor = .clear
        head.position = CGPoint(x: 52, y: 115)
        root.addChild(head)

        let eye = SKShapeNode(circleOfRadius: 3)
        eye.fillColor = .black
        eye.strokeColor = .clear
        eye.position = CGPoint(x: 58, y: 117)
        root.addChild(eye)

        let tail = SKSpriteNode(color: SKColor(red: 0.35, green: 0.50, blue: 0.35, alpha: 1),
                                 size: CGSize(width: 50, height: 10))
        tail.position = CGPoint(x: -55, y: 35)
        tail.zRotation = -0.15
        root.addChild(tail)

        for xOff: CGFloat in [-20, 0, 20, 35] {
            let leg = SKSpriteNode(color: SKColor(red: 0.35, green: 0.45, blue: 0.35, alpha: 1),
                                    size: CGSize(width: 14, height: 30))
            leg.position = CGPoint(x: xOff, y: 0)
            root.addChild(leg)
        }
    }

    private static func makeTriceratops(root: SKNode) {
        let body = SKSpriteNode(color: SKColor(red: 0.55, green: 0.50, blue: 0.35, alpha: 1),
                                 size: CGSize(width: 60, height: 40))
        body.position = CGPoint(x: 0, y: 20)
        root.addChild(body)

        let frill = SKShapeNode(circleOfRadius: 22)
        frill.fillColor = SKColor(red: 0.65, green: 0.55, blue: 0.35, alpha: 1)
        frill.strokeColor = SKColor(red: 0.50, green: 0.40, blue: 0.25, alpha: 1)
        frill.lineWidth = 2
        frill.position = CGPoint(x: 30, y: 35)
        root.addChild(frill)

        let head = SKShapeNode(ellipseOf: CGSize(width: 28, height: 22))
        head.fillColor = SKColor(red: 0.60, green: 0.55, blue: 0.40, alpha: 1)
        head.strokeColor = .clear
        head.position = CGPoint(x: 38, y: 25)
        root.addChild(head)

        // Horns
        for angle: CGFloat in [-0.4, 0, 0.4] {
            let horn = SKSpriteNode(color: SKColor(red: 0.90, green: 0.85, blue: 0.70, alpha: 1),
                                     size: CGSize(width: 4, height: 16))
            horn.position = CGPoint(x: 42 + cos(angle) * 8, y: 40 + sin(angle) * 8)
            horn.zRotation = angle + 0.3
            root.addChild(horn)
        }

        let eye = SKShapeNode(circleOfRadius: 3)
        eye.fillColor = .black
        eye.strokeColor = .clear
        eye.position = CGPoint(x: 44, y: 27)
        root.addChild(eye)
    }

    private static func makePterodactyl(root: SKNode) {
        let body = SKSpriteNode(color: SKColor(red: 0.50, green: 0.45, blue: 0.35, alpha: 1),
                                 size: CGSize(width: 30, height: 18))
        body.position = CGPoint(x: 0, y: 0)
        root.addChild(body)

        let head = SKShapeNode(ellipseOf: CGSize(width: 20, height: 12))
        head.fillColor = SKColor(red: 0.55, green: 0.50, blue: 0.40, alpha: 1)
        head.strokeColor = .clear
        head.position = CGPoint(x: 20, y: 4)
        root.addChild(head)

        let beak = SKSpriteNode(color: SKColor(red: 0.70, green: 0.55, blue: 0.30, alpha: 1),
                                 size: CGSize(width: 15, height: 5))
        beak.position = CGPoint(x: 35, y: 2)
        root.addChild(beak)

        // Wings
        let leftWing = SKSpriteNode(color: SKColor(red: 0.55, green: 0.50, blue: 0.38, alpha: 1),
                                     size: CGSize(width: 45, height: 8))
        leftWing.position = CGPoint(x: -5, y: 8)
        leftWing.zRotation = 0.15
        root.addChild(leftWing)

        let rightWing = SKSpriteNode(color: SKColor(red: 0.55, green: 0.50, blue: 0.38, alpha: 1),
                                      size: CGSize(width: 45, height: 8))
        rightWing.position = CGPoint(x: -5, y: -8)
        rightWing.zRotation = -0.15
        root.addChild(rightWing)

        let wingFlap = SKAction.sequence([
            SKAction.rotate(byAngle: 0.3, duration: 0.4),
            SKAction.rotate(byAngle: -0.3, duration: 0.4)
        ])
        leftWing.run(SKAction.repeatForever(wingFlap))
        rightWing.run(SKAction.repeatForever(wingFlap.reversed()))
    }

    private static func makeTRex(root: SKNode) {
        let body = SKSpriteNode(color: SKColor(red: 0.55, green: 0.30, blue: 0.15, alpha: 1),
                                 size: CGSize(width: 70, height: 50))
        body.position = CGPoint(x: 0, y: 35)
        root.addChild(body)

        let head = SKShapeNode(ellipseOf: CGSize(width: 40, height: 30))
        head.fillColor = SKColor(red: 0.60, green: 0.35, blue: 0.18, alpha: 1)
        head.strokeColor = .clear
        head.position = CGPoint(x: 40, y: 50)
        root.addChild(head)

        // Jaw
        let jaw = SKSpriteNode(color: SKColor(red: 0.50, green: 0.25, blue: 0.12, alpha: 1),
                                size: CGSize(width: 30, height: 12))
        jaw.position = CGPoint(x: 48, y: 38)
        root.addChild(jaw)

        // Teeth
        for i in 0..<4 {
            let tooth = SKSpriteNode(color: .white, size: CGSize(width: 3, height: 5))
            tooth.position = CGPoint(x: CGFloat(36 + i * 7), y: 43)
            root.addChild(tooth)
        }

        let eye = SKShapeNode(circleOfRadius: 4)
        eye.fillColor = .yellow
        eye.strokeColor = .red
        eye.lineWidth = 1
        eye.position = CGPoint(x: 48, y: 55)
        root.addChild(eye)

        let pupil = SKShapeNode(circleOfRadius: 2)
        pupil.fillColor = .black
        pupil.strokeColor = .clear
        pupil.position = CGPoint(x: 49, y: 55)
        root.addChild(pupil)

        // Small arms
        let arm = SKSpriteNode(color: SKColor(red: 0.55, green: 0.30, blue: 0.15, alpha: 1),
                                size: CGSize(width: 8, height: 14))
        arm.position = CGPoint(x: 22, y: 28)
        root.addChild(arm)

        let tail = SKSpriteNode(color: SKColor(red: 0.50, green: 0.28, blue: 0.13, alpha: 1),
                                 size: CGSize(width: 45, height: 15))
        tail.position = CGPoint(x: -48, y: 35)
        tail.zRotation = -0.1
        root.addChild(tail)

        for xOff: CGFloat in [-10, 15] {
            let leg = SKSpriteNode(color: SKColor(red: 0.48, green: 0.26, blue: 0.12, alpha: 1),
                                    size: CGSize(width: 16, height: 30))
            leg.position = CGPoint(x: xOff, y: -5)
            root.addChild(leg)
        }
    }

    private static func makeStegosaurus(root: SKNode) {
        let body = SKSpriteNode(color: SKColor(red: 0.45, green: 0.50, blue: 0.30, alpha: 1),
                                 size: CGSize(width: 65, height: 35))
        body.position = CGPoint(x: 0, y: 20)
        root.addChild(body)

        let head = SKShapeNode(ellipseOf: CGSize(width: 20, height: 16))
        head.fillColor = SKColor(red: 0.50, green: 0.55, blue: 0.35, alpha: 1)
        head.strokeColor = .clear
        head.position = CGPoint(x: 38, y: 18)
        root.addChild(head)

        // Plates on back
        for i in 0..<5 {
            let plate = SKShapeNode(ellipseOf: CGSize(width: 10, height: 14))
            plate.fillColor = SKColor(red: 0.60, green: 0.45, blue: 0.20, alpha: 1)
            plate.strokeColor = .clear
            plate.position = CGPoint(x: CGFloat(-20 + i * 12), y: 42)
            root.addChild(plate)
        }

        let eye = SKShapeNode(circleOfRadius: 2)
        eye.fillColor = .black
        eye.strokeColor = .clear
        eye.position = CGPoint(x: 44, y: 20)
        root.addChild(eye)

        // Tail spikes
        for i in 0..<2 {
            let spike = SKSpriteNode(color: SKColor(red: 0.70, green: 0.55, blue: 0.25, alpha: 1),
                                      size: CGSize(width: 4, height: 12))
            spike.position = CGPoint(x: CGFloat(-38 - i * 8), y: 28)
            spike.zRotation = CGFloat(-0.3 - Double(i) * 0.2)
            root.addChild(spike)
        }
    }

    private static func makeCoelophysis(root: SKNode) {
        let body = SKSpriteNode(color: SKColor(red: 0.55, green: 0.45, blue: 0.30, alpha: 1),
                                 size: CGSize(width: 35, height: 18))
        body.position = CGPoint(x: 0, y: 10)
        root.addChild(body)

        let head = SKShapeNode(ellipseOf: CGSize(width: 16, height: 12))
        head.fillColor = SKColor(red: 0.60, green: 0.50, blue: 0.35, alpha: 1)
        head.strokeColor = .clear
        head.position = CGPoint(x: 22, y: 14)
        root.addChild(head)

        let eye = SKShapeNode(circleOfRadius: 2)
        eye.fillColor = .black
        eye.strokeColor = .clear
        eye.position = CGPoint(x: 26, y: 16)
        root.addChild(eye)

        let tail = SKSpriteNode(color: SKColor(red: 0.50, green: 0.40, blue: 0.28, alpha: 1),
                                 size: CGSize(width: 22, height: 6))
        tail.position = CGPoint(x: -24, y: 12)
        tail.zRotation = 0.15
        root.addChild(tail)
    }

    private static func makePlateosaurus(root: SKNode) {
        let body = SKSpriteNode(color: SKColor(red: 0.50, green: 0.42, blue: 0.28, alpha: 1),
                                 size: CGSize(width: 55, height: 35))
        body.position = CGPoint(x: 0, y: 25)
        root.addChild(body)

        let neck = SKSpriteNode(color: SKColor(red: 0.55, green: 0.47, blue: 0.32, alpha: 1),
                                 size: CGSize(width: 12, height: 35))
        neck.position = CGPoint(x: 25, y: 50)
        neck.zRotation = 0.25
        root.addChild(neck)

        let head = SKShapeNode(ellipseOf: CGSize(width: 18, height: 14))
        head.fillColor = SKColor(red: 0.55, green: 0.47, blue: 0.32, alpha: 1)
        head.strokeColor = .clear
        head.position = CGPoint(x: 36, y: 70)
        root.addChild(head)

        let eye = SKShapeNode(circleOfRadius: 2)
        eye.fillColor = .black
        eye.strokeColor = .clear
        eye.position = CGPoint(x: 40, y: 72)
        root.addChild(eye)

        let tail = SKSpriteNode(color: SKColor(red: 0.45, green: 0.38, blue: 0.25, alpha: 1),
                                 size: CGSize(width: 35, height: 10))
        tail.position = CGPoint(x: -38, y: 22)
        tail.zRotation = -0.1
        root.addChild(tail)
    }

    // MARK: - Coin

    static func makeCoin() -> SKNode {
        let coin = SKShapeNode(circleOfRadius: Constants.coinSize / 2)
        coin.fillColor = ColorPalette.goldColor
        coin.strokeColor = SKColor(red: 0.85, green: 0.70, blue: 0.0, alpha: 1)
        coin.lineWidth = 2
        coin.name = "coin"

        let label = SKLabelNode(text: "$")
        label.fontName = Constants.fontName
        label.fontSize = 14
        label.fontColor = SKColor(red: 0.75, green: 0.55, blue: 0.0, alpha: 1)
        label.verticalAlignmentMode = .center
        coin.addChild(label)

        // Spin animation
        let spin = SKAction.sequence([
            SKAction.scaleX(to: 0.2, duration: 0.3),
            SKAction.scaleX(to: 1.0, duration: 0.3)
        ])
        coin.run(SKAction.repeatForever(spin))

        return coin
    }

    // MARK: - End Flag

    static func makeEndFlag() -> SKNode {
        let root = SKNode()
        root.name = "endFlag"

        let pole = SKSpriteNode(color: .gray, size: CGSize(width: 6, height: 120))
        pole.position = CGPoint(x: 0, y: 60)
        root.addChild(pole)

        let flag = SKSpriteNode(color: .green, size: CGSize(width: 40, height: 25))
        flag.position = CGPoint(x: 22, y: 108)
        root.addChild(flag)

        let star = SKLabelNode(text: "★")
        star.fontSize = 20
        star.fontColor = .yellow
        star.position = CGPoint(x: 22, y: 103)
        root.addChild(star)

        // Flag wave
        let wave = SKAction.sequence([
            SKAction.moveBy(x: 3, y: 0, duration: 0.5),
            SKAction.moveBy(x: -3, y: 0, duration: 0.5)
        ])
        flag.run(SKAction.repeatForever(wave))

        return root
    }

    // MARK: - Trees

    static func makeTree(era: Era) -> SKNode {
        let colors = ColorPalette.colors(for: era)
        let root = SKNode()

        let trunkHeight: CGFloat = CGFloat.random(in: 60...120)
        let trunk = SKSpriteNode(color: colors.treeTrunk, size: CGSize(width: 14, height: trunkHeight))
        trunk.position = CGPoint(x: 0, y: trunkHeight / 2)
        root.addChild(trunk)

        switch era {
        case .triassic:
            // Small ferns - triangular
            for i in 0..<3 {
                let size = CGFloat(25 - i * 5)
                let leaf = SKShapeNode(rectOf: CGSize(width: size, height: size * 0.8))
                leaf.fillColor = colors.treeLeaves
                leaf.strokeColor = .clear
                leaf.position = CGPoint(x: 0, y: trunkHeight - CGFloat(i) * 18 + 10)
                leaf.zRotation = .pi / 4
                root.addChild(leaf)
            }
        case .jurassic:
            // Tall trees with big circular canopy
            let canopy = SKShapeNode(circleOfRadius: 35)
            canopy.fillColor = colors.treeLeaves
            canopy.strokeColor = colors.treeLeaves.withAlphaComponent(0.7)
            canopy.lineWidth = 3
            canopy.position = CGPoint(x: 0, y: trunkHeight + 20)
            root.addChild(canopy)

            let canopy2 = SKShapeNode(circleOfRadius: 25)
            canopy2.fillColor = colors.treeLeaves.withAlphaComponent(0.8)
            canopy2.strokeColor = .clear
            canopy2.position = CGPoint(x: 15, y: trunkHeight + 5)
            root.addChild(canopy2)
        case .cretaceous:
            // Sparse, volcanic era trees
            let canopy = SKShapeNode(ellipseOf: CGSize(width: 30, height: 20))
            canopy.fillColor = colors.treeLeaves
            canopy.strokeColor = .clear
            canopy.position = CGPoint(x: 0, y: trunkHeight + 8)
            root.addChild(canopy)
        }

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

        let bg = SKShapeNode(rectOf: CGSize(width: 28, height: 28), cornerRadius: 6)
        bg.strokeColor = .white
        bg.lineWidth = 2
        root.addChild(bg)

        let label = SKLabelNode()
        label.fontSize = 18
        label.verticalAlignmentMode = .center

        switch type {
        case .extraLife:
            bg.fillColor = ColorPalette.heartColor
            label.text = "♥"
        case .shield:
            bg.fillColor = SKColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1)
            label.text = "🛡"
        case .speedBoost:
            bg.fillColor = SKColor(red: 0.9, green: 0.7, blue: 0.1, alpha: 1)
            label.text = "⚡"
        }

        root.addChild(label)

        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 8, duration: 0.6),
            SKAction.moveBy(x: 0, y: -8, duration: 0.6)
        ])
        root.run(SKAction.repeatForever(bounce))

        return root
    }
}
