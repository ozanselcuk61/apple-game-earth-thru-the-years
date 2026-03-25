import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // Core components
    private var player: PlayerCharacter!
    private var robot: RobotCompanion!
    private var cameraManager: CameraManager!
    private var touchControls: TouchControlManager!
    private var hud: HUD!
    private var parallaxBackground: ParallaxBackground!

    // Level components
    private var levelComponents: LevelComponents!
    private let levelData: LevelData
    private var dinosaurs: [Dinosaur] = []

    // State
    private var lastUpdateTime: TimeInterval = 0
    private var isLevelComplete = false
    private var isPaused2 = false // avoid conflict with SKScene.isPaused
    private var previousGoldForExtraLife: Int = 0

    override init(size: CGSize) {
        self.levelData = LevelCatalog.level(era: GameManager.shared.currentEra,
                                             subLevel: GameManager.shared.currentLevel)
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        // Enable multitouch!
        view.isMultipleTouchEnabled = true

        setupPhysics()
        setupBackground()
        buildLevel()
        setupPlayer()
        setupRobot()
        setupCamera()
        setupHUD()
        setupControls()
        setupPauseButton()

        previousGoldForExtraLife = GameManager.shared.totalGold
    }

    // MARK: - Setup

    private func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: Constants.gravity)
        physicsWorld.contactDelegate = self
    }

    private func setupBackground() {
        parallaxBackground = ParallaxBackground(scene: self, era: GameManager.shared.currentEra)
    }

    private func buildLevel() {
        let builder = LevelBuilder(levelData: levelData, scene: self)
        levelComponents = builder.build()
        dinosaurs = levelComponents.dinosaurs
    }

    private func setupPlayer() {
        player = PlayerCharacter(type: GameManager.shared.selectedCharacter)
        player.position = CGPoint(x: 150, y: Constants.groundHeight + 5)
        addChild(player)
    }

    private func setupRobot() {
        robot = RobotCompanion(target: player)
        robot.position = CGPoint(x: 100, y: Constants.groundHeight + 20)
        addChild(robot)
    }

    private func setupCamera() {
        cameraManager = CameraManager(scene: self, levelWidth: levelComponents.levelWidth)
    }

    private func setupHUD() {
        hud = HUD()
        cameraManager.cameraNode.addChild(hud)

        hud.updateLives(GameManager.shared.lives)
        hud.updateGold(GameManager.shared.levelGold)
        hud.updateLevel(era: GameManager.shared.currentEra, level: GameManager.shared.currentLevel)
        hud.showGoldRequirement(current: 0, required: levelData.minimumGold)
    }

    private func setupControls() {
        touchControls = TouchControlManager()
        cameraManager.cameraNode.addChild(touchControls)
    }

    private func setupPauseButton() {
        let pauseButton = SKShapeNode(rectOf: CGSize(width: 55, height: 55), cornerRadius: 12)
        pauseButton.fillColor = SKColor(white: 0.15, alpha: 0.7)
        pauseButton.strokeColor = SKColor(white: 0.6, alpha: 0.6)
        pauseButton.lineWidth = 2
        pauseButton.position = CGPoint(x: -600, y: 290)
        pauseButton.name = "pauseButton"
        pauseButton.zPosition = Constants.ZPosition.hud

        let pauseLabel = SKLabelNode(text: "⏸")
        pauseLabel.fontSize = 28
        pauseLabel.verticalAlignmentMode = .center
        pauseLabel.name = "pauseButton"
        pauseButton.addChild(pauseLabel)

        cameraManager.cameraNode.addChild(pauseButton)
    }

    // MARK: - Game Loop

    override func update(_ currentTime: TimeInterval) {
        guard !isLevelComplete && !isPaused2 else { return }

        let deltaTime: TimeInterval
        if lastUpdateTime == 0 {
            deltaTime = 1.0 / 60.0
        } else {
            deltaTime = currentTime - lastUpdateTime
        }
        lastUpdateTime = currentTime

        // Player input
        let input = touchControls.inputState
        player.applyMovement(direction: input.horizontalDirection)
        if input.jumpPressed {
            player.jump()
        }

        // Updates
        player.update(deltaTime: deltaTime)
        robot.update(deltaTime: deltaTime)

        for dino in dinosaurs where dino.isAlive {
            dino.update(deltaTime: deltaTime)
        }

        cameraManager.update(playerPosition: player.position)
        parallaxBackground.update(cameraX: cameraManager.cameraNode.position.x - size.width / 2)

        // HUD updates
        hud.updateGold(GameManager.shared.levelGold)
        hud.updateLives(player.health.lives)
        hud.showGoldRequirement(current: GameManager.shared.levelGold, required: levelData.minimumGold)

        // Progress
        let progress = player.position.x / levelComponents.levelWidth
        hud.updateProgress(progress)

        // Check for extra life
        checkExtraLife()

        // Check if player fell off the world
        if player.position.y < -200 {
            handlePlayerDeath()
        }

        touchControls.postUpdate()
    }

    // MARK: - Physics Contact

    func didBegin(_ contact: SKPhysicsContact) {
        let (bodyA, bodyB) = sortBodies(contact)

        // Player + Coin
        if bodyA.categoryBitMask == PhysicsCategory.player && bodyB.categoryBitMask == PhysicsCategory.coin {
            if let coin = bodyB.node?.parent as? Coin ?? bodyB.node as? Coin {
                coin.collect()
                GameManager.shared.collectGold()
                AudioManager.shared.playCoinSound(on: self)
            }
            return
        }

        // Player + Enemy
        if bodyA.categoryBitMask == PhysicsCategory.player && bodyB.categoryBitMask == PhysicsCategory.enemy {
            if let dino = findDinosaur(from: bodyB.node) {
                if dino.isStompedBy(player: player) {
                    // Player stomped the dinosaur
                    dino.defeat()
                    player.physicsBody?.velocity.dy = Constants.playerJumpImpulse * 0.6
                    GameManager.shared.collectGold(dino.type.points)
                    AudioManager.shared.playEnemyDefeatSound(on: self)
                } else {
                    // Player takes damage
                    if player.takeDamage() {
                        player.syncLivesToManager()
                        if !player.health.isAlive {
                            handlePlayerDeath()
                        }
                    }
                }
            }
            return
        }

        // Player + PowerUp
        if bodyA.categoryBitMask == PhysicsCategory.player && bodyB.categoryBitMask == PhysicsCategory.powerUp {
            if let powerUp = bodyB.node?.parent as? PowerUp ?? bodyB.node as? PowerUp {
                powerUp.collect(player: player)
            }
            return
        }

        // Player + Boundary (death)
        if bodyA.categoryBitMask == PhysicsCategory.player && bodyB.categoryBitMask == PhysicsCategory.boundary {
            handlePlayerDeath()
            return
        }

        // Player + End Flag
        if bodyA.categoryBitMask == PhysicsCategory.player && bodyB.categoryBitMask == PhysicsCategory.endFlag {
            handleLevelComplete()
            return
        }

        // Player + Ground (grounding detection)
        if bodyA.categoryBitMask == PhysicsCategory.player &&
           (bodyB.categoryBitMask == PhysicsCategory.ground || bodyB.categoryBitMask == PhysicsCategory.platform) {
            if (player.physicsBody?.velocity.dy ?? 0) <= 1 {
                player.setGrounded(true)
            }
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let (bodyA, bodyB) = sortBodies(contact)

        if bodyA.categoryBitMask == PhysicsCategory.player &&
           (bodyB.categoryBitMask == PhysicsCategory.ground || bodyB.categoryBitMask == PhysicsCategory.platform) {
            // Small delay before setting ungrounded to handle edge cases
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                if (self?.player.physicsBody?.velocity.dy ?? 0) > 1 ||
                   (self?.player.physicsBody?.velocity.dy ?? 0) < -1 {
                    self?.player.setGrounded(false)
                }
            }
        }
    }

    private func sortBodies(_ contact: SKPhysicsContact) -> (SKPhysicsBody, SKPhysicsBody) {
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            return (contact.bodyA, contact.bodyB)
        }
        return (contact.bodyB, contact.bodyA)
    }

    private func findDinosaur(from node: SKNode?) -> Dinosaur? {
        var current = node
        while let n = current {
            if let dino = n as? Dinosaur { return dino }
            current = n.parent
        }
        return nil
    }

    // MARK: - Game Events

    private func checkExtraLife() {
        let currentGold = GameManager.shared.totalGold
        let previousHundreds = previousGoldForExtraLife / Constants.goldForExtraLife
        let currentHundreds = currentGold / Constants.goldForExtraLife

        if currentHundreds > previousHundreds {
            hud.showExtraLifeAnimation()
            hud.updateLives(GameManager.shared.lives)
        }
        previousGoldForExtraLife = currentGold
    }

    private func handlePlayerDeath() {
        guard !isLevelComplete else { return }

        if GameManager.shared.loseLife() {
            // Respawn player
            player.position = CGPoint(x: max(150, player.position.x - 300), y: Constants.groundHeight + 30)
            player.physicsBody?.velocity = .zero
            player.health.setLives(GameManager.shared.lives)
            hud.updateLives(GameManager.shared.lives)
        } else {
            // Game over
            isLevelComplete = true
            AudioManager.shared.playGameOverSound(on: self)
            let gameOverScene = GameOverScene(size: size)
            transitionTo(gameOverScene)
        }
    }

    private func handleLevelComplete() {
        guard !isLevelComplete else { return }

        // Check minimum gold requirement
        if GameManager.shared.levelGold < levelData.minimumGold {
            // Show warning - not enough gold
            let warning = SKLabelNode(text: "Yeterli altın toplanmadı! (\(GameManager.shared.levelGold)/\(levelData.minimumGold))")
            warning.fontName = Constants.fontName
            warning.fontSize = 20
            warning.fontColor = .red
            warning.position = CGPoint(x: 0, y: 0)
            warning.zPosition = Constants.ZPosition.overlay
            cameraManager.cameraNode.addChild(warning)

            let fadeAction = SKAction.sequence([
                SKAction.wait(forDuration: 2.0),
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.removeFromParent()
            ])
            warning.run(fadeAction)
            return
        }

        isLevelComplete = true
        AudioManager.shared.playLevelCompleteSound(on: self)
        GameManager.shared.completeCurrentLevel()
        player.syncLivesToManager()

        let completeScene = LevelCompleteScene(size: size, goldCollected: GameManager.shared.levelGold,
                                                 minimumGold: levelData.minimumGold)
        transitionTo(completeScene, duration: 1.0)
    }

    // MARK: - Touch Handling (multitouch)

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: cameraManager.cameraNode)
            let touchedNodes = cameraManager.cameraNode.nodes(at: location)

            // Check UI buttons first
            var handledByUI = false
            for node in touchedNodes {
                if node.name == "pauseButton" {
                    togglePause()
                    handledByUI = true
                    break
                }
                if node.name == "resumeButton" || (node.name ?? "").hasPrefix("Devam") {
                    togglePause()
                    handledByUI = true
                    break
                }
                if node.name == "quitButton" || (node.name ?? "").hasPrefix("Çık") {
                    let menuScene = MainMenuScene(size: size)
                    transitionTo(menuScene)
                    handledByUI = true
                    break
                }
            }

            // If not a UI button, forward to touch controls
            if !handledByUI {
                touchControls.handleTouchBegan(touch, in: cameraManager.cameraNode)
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchControls.handleTouchMoved(touch, in: cameraManager.cameraNode)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchControls.handleTouchEnded(touch)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchControls.handleTouchEnded(touch)
        }
    }

    private func togglePause() {
        isPaused2 = !isPaused2
        physicsWorld.speed = isPaused2 ? 0 : 1

        if isPaused2 {
            showPauseOverlay()
        } else {
            cameraManager.cameraNode.childNode(withName: "pauseOverlay")?.removeFromParent()
        }
    }

    private func showPauseOverlay() {
        let overlay = SKNode()
        overlay.name = "pauseOverlay"
        overlay.zPosition = Constants.ZPosition.overlay

        let bg = SKShapeNode(rectOf: CGSize(width: 400, height: 300), cornerRadius: 20)
        bg.fillColor = SKColor(white: 0, alpha: 0.8)
        bg.strokeColor = ColorPalette.goldColor.withAlphaComponent(0.5)
        bg.lineWidth = 2
        overlay.addChild(bg)

        let title = SKLabelNode(text: "DURAKLADI")
        title.fontName = Constants.fontName
        title.fontSize = 28
        title.fontColor = ColorPalette.goldColor
        title.position = CGPoint(x: 0, y: 80)
        overlay.addChild(title)

        let resumeButton = NodeFactory.makeButton(text: "Devam Et", size: CGSize(width: 200, height: 50))
        resumeButton.position = CGPoint(x: 0, y: 10)
        resumeButton.name = "resumeButton"
        overlay.addChild(resumeButton)

        let quitButton = NodeFactory.makeButton(text: "Çık", size: CGSize(width: 200, height: 50))
        quitButton.position = CGPoint(x: 0, y: -60)
        quitButton.name = "quitButton"
        overlay.addChild(quitButton)

        cameraManager.cameraNode.addChild(overlay)
    }
}
