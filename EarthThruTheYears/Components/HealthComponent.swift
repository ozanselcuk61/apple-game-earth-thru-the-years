import SpriteKit

class HealthComponent {
    private(set) var lives: Int
    private(set) var isInvincible = false
    private var invincibilityTimer: TimeInterval = 0

    init(lives: Int) {
        self.lives = lives
    }

    var isAlive: Bool { lives > 0 }

    func takeDamage() -> Bool {
        guard !isInvincible, isAlive else { return false }
        lives -= 1
        isInvincible = true
        invincibilityTimer = Constants.invincibilityDuration
        return true
    }

    func addLife() {
        lives += 1
    }

    func setLives(_ count: Int) {
        lives = count
    }

    func update(deltaTime: TimeInterval) {
        if isInvincible {
            invincibilityTimer -= deltaTime
            if invincibilityTimer <= 0 {
                isInvincible = false
                invincibilityTimer = 0
            }
        }
    }

    func applyInvincibilityVisual(to node: SKNode) {
        if isInvincible {
            let blink = Int(invincibilityTimer * 10) % 2 == 0
            node.alpha = blink ? 0.4 : 1.0
        } else {
            node.alpha = 1.0
        }
    }
}
