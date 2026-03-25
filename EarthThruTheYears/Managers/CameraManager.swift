import SpriteKit

class CameraManager {
    let cameraNode: SKCameraNode
    private var levelWidth: CGFloat = 0
    private let sceneSize: CGSize

    init(scene: SKScene, levelWidth: CGFloat) {
        self.cameraNode = SKCameraNode()
        self.levelWidth = levelWidth
        self.sceneSize = scene.size
        scene.addChild(cameraNode)
        scene.camera = cameraNode

        // Start camera at the left edge
        cameraNode.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
    }

    func update(playerPosition: CGPoint) {
        let targetX = playerPosition.x
        let minX = sceneSize.width / 2
        let maxX = max(levelWidth - sceneSize.width / 2, minX)
        let clampedX = targetX.clamped(to: minX...maxX)

        let currentX = cameraNode.position.x
        let newX = CGFloat.lerp(from: currentX, to: clampedX, t: Constants.cameraLerpFactor)
        cameraNode.position.x = newX
        cameraNode.position.y = sceneSize.height / 2
    }

    func setLevelWidth(_ width: CGFloat) {
        self.levelWidth = width
    }
}
