import SpriteKit

struct EraColors {
    let skyTop: SKColor
    let skyBottom: SKColor
    let groundTop: SKColor
    let groundBottom: SKColor
    let treeTrunk: SKColor
    let treeLeaves: SKColor
    let platform: SKColor
    let accent: SKColor
}

enum ColorPalette {
    static func colors(for era: Era) -> EraColors {
        switch era {
        case .triassic:
            return EraColors(
                skyTop: SKColor(red: 0.95, green: 0.75, blue: 0.45, alpha: 1),
                skyBottom: SKColor(red: 0.85, green: 0.65, blue: 0.35, alpha: 1),
                groundTop: SKColor(red: 0.72, green: 0.58, blue: 0.36, alpha: 1),
                groundBottom: SKColor(red: 0.55, green: 0.40, blue: 0.25, alpha: 1),
                treeTrunk: SKColor(red: 0.45, green: 0.30, blue: 0.15, alpha: 1),
                treeLeaves: SKColor(red: 0.30, green: 0.50, blue: 0.20, alpha: 1),
                platform: SKColor(red: 0.60, green: 0.45, blue: 0.30, alpha: 1),
                accent: SKColor(red: 0.90, green: 0.60, blue: 0.20, alpha: 1)
            )
        case .jurassic:
            return EraColors(
                skyTop: SKColor(red: 0.20, green: 0.55, blue: 0.80, alpha: 1),
                skyBottom: SKColor(red: 0.30, green: 0.65, blue: 0.50, alpha: 1),
                groundTop: SKColor(red: 0.25, green: 0.50, blue: 0.15, alpha: 1),
                groundBottom: SKColor(red: 0.20, green: 0.35, blue: 0.10, alpha: 1),
                treeTrunk: SKColor(red: 0.35, green: 0.25, blue: 0.10, alpha: 1),
                treeLeaves: SKColor(red: 0.15, green: 0.60, blue: 0.15, alpha: 1),
                platform: SKColor(red: 0.35, green: 0.55, blue: 0.25, alpha: 1),
                accent: SKColor(red: 0.20, green: 0.70, blue: 0.30, alpha: 1)
            )
        case .cretaceous:
            return EraColors(
                skyTop: SKColor(red: 0.35, green: 0.15, blue: 0.25, alpha: 1),
                skyBottom: SKColor(red: 0.55, green: 0.20, blue: 0.15, alpha: 1),
                groundTop: SKColor(red: 0.35, green: 0.30, blue: 0.28, alpha: 1),
                groundBottom: SKColor(red: 0.25, green: 0.20, blue: 0.18, alpha: 1),
                treeTrunk: SKColor(red: 0.30, green: 0.20, blue: 0.15, alpha: 1),
                treeLeaves: SKColor(red: 0.40, green: 0.35, blue: 0.20, alpha: 1),
                platform: SKColor(red: 0.45, green: 0.35, blue: 0.30, alpha: 1),
                accent: SKColor(red: 0.85, green: 0.30, blue: 0.15, alpha: 1)
            )
        }
    }

    // Menu/UI colors
    static let menuBackground = SKColor(red: 0.12, green: 0.20, blue: 0.12, alpha: 1)
    static let buttonColor = SKColor(red: 0.25, green: 0.60, blue: 0.25, alpha: 1)
    static let buttonHighlight = SKColor(red: 0.35, green: 0.75, blue: 0.35, alpha: 1)
    static let goldColor = SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1)
    static let textColor = SKColor.white
    static let textShadow = SKColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    static let heartColor = SKColor(red: 0.90, green: 0.15, blue: 0.20, alpha: 1)
    static let lockedColor = SKColor(red: 0.40, green: 0.40, blue: 0.40, alpha: 1)

    // Character colors
    static let boyColor = SKColor(red: 0.30, green: 0.50, blue: 0.85, alpha: 1)
    static let girlColor = SKColor(red: 0.85, green: 0.40, blue: 0.60, alpha: 1)
    static let skinColor = SKColor(red: 0.95, green: 0.80, blue: 0.65, alpha: 1)
    static let robotColor = SKColor(red: 0.65, green: 0.70, blue: 0.75, alpha: 1)
    static let robotAccent = SKColor(red: 0.30, green: 0.85, blue: 0.95, alpha: 1)
}
