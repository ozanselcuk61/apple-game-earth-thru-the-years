import SpriteKit

enum Constants {
    // Scene size (iPhone landscape base, aspect-fill scales for iPad)
    static let sceneSize = CGSize(width: 1334, height: 750)

    // Physics
    static let gravity: CGFloat = -18.0
    static let playerMoveSpeed: CGFloat = 380.0
    static let playerJumpImpulse: CGFloat = 700.0
    static let maxPlayerVelocityY: CGFloat = 900.0

    // Gameplay
    static let startingLives = 3
    static let goldForExtraLife = 100
    static let invincibilityDuration: TimeInterval = 2.0

    // Camera
    static let cameraLerpFactor: CGFloat = 0.1

    // Tile sizes
    static let tileSize: CGFloat = 50.0
    static let groundHeight: CGFloat = 120.0

    // Coin
    static let coinSize: CGFloat = 30.0
    static let coinValue = 1

    // Z-positions (layering)
    enum ZPosition {
        static let background: CGFloat = -100
        static let backgroundLayer1: CGFloat = -90
        static let backgroundLayer2: CGFloat = -80
        static let backgroundLayer3: CGFloat = -70
        static let ground: CGFloat = 0
        static let decoration: CGFloat = 5
        static let coin: CGFloat = 10
        static let powerUp: CGFloat = 10
        static let enemy: CGFloat = 15
        static let player: CGFloat = 20
        static let robot: CGFloat = 19
        static let foreground: CGFloat = 50
        static let hud: CGFloat = 100
        static let overlay: CGFloat = 200
    }

    // Font
    static let fontName = "AvenirNext-Bold"
    static let fontNameRegular = "AvenirNext-Regular"
}
