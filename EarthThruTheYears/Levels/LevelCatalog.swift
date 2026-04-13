import CoreGraphics

enum LevelCatalog {

    static let sceneWidth = Constants.sceneSize.width

    static func level(era: Era, subLevel: Int) -> LevelData {
        switch era {
        case .triassic:
            return triassicLevel(subLevel)
        case .jurassic:
            return jurassicLevel(subLevel)
        case .cretaceous:
            return cretaceousLevel(subLevel)
        }
    }

    // MARK: - Trias Dönemi

    private static func triassicLevel(_ subLevel: Int) -> LevelData {
        switch subLevel {
        case 1:
            return LevelData(
                era: .triassic, subLevel: 1,
                totalWidth: sceneWidth * 8,
                minimumGold: 15,
                totalCoins: 40,
                platformCount: 6,
                enemyCount: 4,
                hasBoss: false,
                powerUpCount: 1
            )
        case 2:
            return LevelData(
                era: .triassic, subLevel: 2,
                totalWidth: sceneWidth * 10,
                minimumGold: 25,
                totalCoins: 55,
                platformCount: 10,
                enemyCount: 7,
                hasBoss: false,
                powerUpCount: 1
            )
        case 3:
            return LevelData(
                era: .triassic, subLevel: 3,
                totalWidth: sceneWidth * 12,
                minimumGold: 35,
                totalCoins: 70,
                platformCount: 14,
                enemyCount: 10,
                hasBoss: false,
                powerUpCount: 2
            )
        default: // 4
            return LevelData(
                era: .triassic, subLevel: 4,
                totalWidth: sceneWidth * 14,
                minimumGold: 50,
                totalCoins: 90,
                platformCount: 16,
                enemyCount: 12,
                hasBoss: true,
                powerUpCount: 2
            )
        }
    }

    // MARK: - Jura Dönemi

    private static func jurassicLevel(_ subLevel: Int) -> LevelData {
        switch subLevel {
        case 1:
            return LevelData(
                era: .jurassic, subLevel: 1,
                totalWidth: sceneWidth * 10,
                minimumGold: 25,
                totalCoins: 55,
                platformCount: 10,
                enemyCount: 6,
                hasBoss: false,
                powerUpCount: 1
            )
        case 2:
            return LevelData(
                era: .jurassic, subLevel: 2,
                totalWidth: sceneWidth * 12,
                minimumGold: 35,
                totalCoins: 70,
                platformCount: 14,
                enemyCount: 9,
                hasBoss: false,
                powerUpCount: 2
            )
        case 3:
            return LevelData(
                era: .jurassic, subLevel: 3,
                totalWidth: sceneWidth * 14,
                minimumGold: 50,
                totalCoins: 90,
                platformCount: 18,
                enemyCount: 12,
                hasBoss: false,
                powerUpCount: 2
            )
        default: // 4
            return LevelData(
                era: .jurassic, subLevel: 4,
                totalWidth: sceneWidth * 16,
                minimumGold: 65,
                totalCoins: 110,
                platformCount: 20,
                enemyCount: 15,
                hasBoss: true,
                powerUpCount: 3
            )
        }
    }

    // MARK: - Kretase Dönemi

    private static func cretaceousLevel(_ subLevel: Int) -> LevelData {
        switch subLevel {
        case 1:
            return LevelData(
                era: .cretaceous, subLevel: 1,
                totalWidth: sceneWidth * 12,
                minimumGold: 35,
                totalCoins: 70,
                platformCount: 12,
                enemyCount: 8,
                hasBoss: false,
                powerUpCount: 2
            )
        case 2:
            return LevelData(
                era: .cretaceous, subLevel: 2,
                totalWidth: sceneWidth * 14,
                minimumGold: 50,
                totalCoins: 90,
                platformCount: 16,
                enemyCount: 12,
                hasBoss: false,
                powerUpCount: 2
            )
        case 3:
            return LevelData(
                era: .cretaceous, subLevel: 3,
                totalWidth: sceneWidth * 16,
                minimumGold: 65,
                totalCoins: 110,
                platformCount: 20,
                enemyCount: 15,
                hasBoss: false,
                powerUpCount: 3
            )
        default: // 4
            return LevelData(
                era: .cretaceous, subLevel: 4,
                totalWidth: sceneWidth * 18,
                minimumGold: 80,
                totalCoins: 130,
                platformCount: 22,
                enemyCount: 18,
                hasBoss: true,
                powerUpCount: 3
            )
        }
    }

    static var allLevels: [LevelData] {
        var levels: [LevelData] = []
        for era in Era.allCases {
            for sub in 1...era.totalLevels {
                levels.append(level(era: era, subLevel: sub))
            }
        }
        return levels
    }
}
