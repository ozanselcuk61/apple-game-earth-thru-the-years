import CoreGraphics

struct LevelData {
    let era: Era
    let subLevel: Int           // 1-4
    let totalWidth: CGFloat     // in points (screen widths * sceneWidth)
    let minimumGold: Int        // required to pass
    let totalCoins: Int         // placed in level
    let platformCount: Int      // number of floating platforms
    let enemyCount: Int
    let hasBoss: Bool
    let powerUpCount: Int

    var displayName: String {
        return "\(era.name) \(subLevel)"
    }

    var levelId: String {
        return "\(era.rawValue)_\(subLevel)"
    }
}
