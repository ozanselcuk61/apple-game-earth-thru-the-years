import SpriteKit

class MarketScene: SKScene {

    private struct MarketItem {
        let id: String
        let name: String
        let description: String
        let price: Int
        let icon: String
    }

    private let items: [MarketItem] = [
        MarketItem(id: "extra_life_pack", name: "Can Paketi", description: "+3 ekstra can", price: 50, icon: "♥"),
        MarketItem(id: "gold_magnet", name: "Altın Mıknatısı", description: "Altınları otomatik topla", price: 100, icon: "🧲"),
        MarketItem(id: "shield_start", name: "Başlangıç Kalkanı", description: "Bölüme kalkanla başla", price: 75, icon: "🛡"),
        MarketItem(id: "double_coins", name: "Çift Altın", description: "Altın değeri 2 katına çıkar", price: 150, icon: "💰"),
        MarketItem(id: "robot_attack", name: "Robot Saldırısı", description: "Robot düşmanları vurabilir", price: 200, icon: "⚡"),
        MarketItem(id: "extra_jump", name: "Çift Zıplama", description: "Havada tekrar zıplayabilirsin", price: 120, icon: "🦘"),
    ]

    override func didMove(to view: SKView) {
        backgroundColor = ColorPalette.menuBackground
        setupUI()
    }

    private func setupUI() {
        // Title
        let title = SKLabelNode(text: "Market")
        title.fontName = Constants.fontName
        title.fontSize = 36
        title.fontColor = ColorPalette.goldColor
        title.position = CGPoint(x: size.width / 2, y: size.height - 70)
        addChild(title)

        // Gold display
        let goldLabel = SKLabelNode(text: "Altınlarım: \(GameManager.shared.totalGold)")
        goldLabel.fontName = Constants.fontName
        goldLabel.fontSize = 20
        goldLabel.fontColor = ColorPalette.goldColor
        goldLabel.position = CGPoint(x: size.width / 2, y: size.height - 110)
        goldLabel.name = "goldDisplay"
        addChild(goldLabel)

        // Items grid (2 columns, 3 rows)
        let startX = size.width / 2 - 200
        let startY = size.height - 180
        let colWidth: CGFloat = 400
        let rowHeight: CGFloat = 90

        for (index, item) in items.enumerated() {
            let col = index % 2
            let row = index / 2
            let x = startX + CGFloat(col) * colWidth
            let y = startY - CGFloat(row) * rowHeight

            let isPurchased = GameManager.shared.marketPurchases.contains(item.id)
            let canAfford = GameManager.shared.totalGold >= item.price

            let card = SKNode()
            card.position = CGPoint(x: x, y: y)
            card.name = "item_\(item.id)"

            let bg = SKShapeNode(rectOf: CGSize(width: 370, height: 75), cornerRadius: 10)
            bg.fillColor = isPurchased ? SKColor(red: 0.15, green: 0.3, blue: 0.15, alpha: 0.8) :
                           SKColor(white: 0.12, alpha: 0.8)
            bg.strokeColor = isPurchased ? .green : (canAfford ? ColorPalette.goldColor : ColorPalette.lockedColor)
            bg.lineWidth = 1.5
            bg.name = "item_\(item.id)"
            card.addChild(bg)

            // Icon
            let icon = SKLabelNode(text: item.icon)
            icon.fontSize = 28
            icon.position = CGPoint(x: -150, y: -8)
            card.addChild(icon)

            // Name
            let nameLabel = SKLabelNode(text: item.name)
            nameLabel.fontName = Constants.fontName
            nameLabel.fontSize = 16
            nameLabel.fontColor = .white
            nameLabel.horizontalAlignmentMode = .left
            nameLabel.position = CGPoint(x: -120, y: 8)
            card.addChild(nameLabel)

            // Description
            let descLabel = SKLabelNode(text: item.description)
            descLabel.fontName = Constants.fontNameRegular
            descLabel.fontSize = 12
            descLabel.fontColor = SKColor(white: 0.7, alpha: 1)
            descLabel.horizontalAlignmentMode = .left
            descLabel.position = CGPoint(x: -120, y: -12)
            card.addChild(descLabel)

            // Price or Purchased
            if isPurchased {
                let ownedLabel = SKLabelNode(text: "✓ Alındı")
                ownedLabel.fontName = Constants.fontName
                ownedLabel.fontSize = 14
                ownedLabel.fontColor = .green
                ownedLabel.position = CGPoint(x: 130, y: -5)
                card.addChild(ownedLabel)
            } else {
                let priceLabel = SKLabelNode(text: "\(item.price) 🪙")
                priceLabel.fontName = Constants.fontName
                priceLabel.fontSize = 14
                priceLabel.fontColor = canAfford ? ColorPalette.goldColor : ColorPalette.lockedColor
                priceLabel.position = CGPoint(x: 130, y: -5)
                card.addChild(priceLabel)
            }

            addChild(card)
        }

        // Back button
        let backButton = NodeFactory.makeButton(text: "Geri", size: CGSize(width: 140, height: 45))
        backButton.position = CGPoint(x: 100, y: 40)
        backButton.name = "backButton"
        addChild(backButton)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            let name = node.name ?? node.parent?.name ?? ""

            // Check market items
            for item in items {
                if name == "item_\(item.id)" {
                    purchaseItem(item)
                    return
                }
            }

            if name == "backButton" || name.hasPrefix("Geri") {
                let scene = MainMenuScene(size: size)
                transitionTo(scene)
                return
            }
        }
    }

    private func purchaseItem(_ item: MarketItem) {
        guard !GameManager.shared.marketPurchases.contains(item.id) else { return }
        guard GameManager.shared.totalGold >= item.price else {
            showMessage("Yeterli altın yok!")
            return
        }

        GameManager.shared.totalGold -= item.price
        GameManager.shared.marketPurchases.insert(item.id)
        GameManager.shared.saveProgress()

        // Refresh UI
        removeAllChildren()
        setupUI()
        showMessage("\(item.name) satın alındı!")
    }

    private func showMessage(_ text: String) {
        let label = SKLabelNode(text: text)
        label.fontName = Constants.fontName
        label.fontSize = 20
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.zPosition = Constants.ZPosition.overlay
        addChild(label)

        let anim = SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ])
        label.run(anim)
    }
}
