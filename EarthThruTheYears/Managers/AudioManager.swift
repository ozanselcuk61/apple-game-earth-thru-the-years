import SpriteKit

class AudioManager {
    static let shared = AudioManager()
    private init() {}

    // Placeholder sound actions - in production, replace with actual audio files
    func playCoinSound(on node: SKNode) {
        guard SaveManager.shared.soundEnabled else { return }
        // In production: node.run(SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false))
    }

    func playJumpSound(on node: SKNode) {
        guard SaveManager.shared.soundEnabled else { return }
    }

    func playHurtSound(on node: SKNode) {
        guard SaveManager.shared.soundEnabled else { return }
    }

    func playEnemyDefeatSound(on node: SKNode) {
        guard SaveManager.shared.soundEnabled else { return }
    }

    func playLevelCompleteSound(on node: SKNode) {
        guard SaveManager.shared.soundEnabled else { return }
    }

    func playGameOverSound(on node: SKNode) {
        guard SaveManager.shared.soundEnabled else { return }
    }

    func playButtonSound(on node: SKNode) {
        guard SaveManager.shared.soundEnabled else { return }
    }
}
