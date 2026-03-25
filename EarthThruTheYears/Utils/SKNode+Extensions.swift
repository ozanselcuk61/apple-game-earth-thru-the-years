import SpriteKit

extension SKNode {
    func addGlow(radius: CGFloat = 30, color: SKColor = .white) {
        let glow = SKEffectNode()
        glow.shouldRasterize = true
        let sprite = SKSpriteNode(color: color, size: CGSize(width: radius * 2, height: radius * 2))
        sprite.alpha = 0.3
        glow.addChild(sprite)
        glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": radius])
        addChild(glow)
    }
}

extension SKSpriteNode {
    static func makeRect(color: SKColor, size: CGSize) -> SKSpriteNode {
        let node = SKSpriteNode(color: color, size: size)
        return node
    }
}

extension SKScene {
    func transitionTo(_ scene: SKScene, duration: TimeInterval = 0.5) {
        scene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: duration)
        view?.presentScene(scene, transition: transition)
    }
}
