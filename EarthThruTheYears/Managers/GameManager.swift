import Foundation

enum CharacterType: String, Codable {
    case boy
    case girl
}

enum Era: Int, CaseIterable, Codable {
    case triassic = 0
    case jurassic = 1
    case cretaceous = 2

    var name: String {
        switch self {
        case .triassic: return "Trias"
        case .jurassic: return "Jura"
        case .cretaceous: return "Kretase"
        }
    }

    var subtitle: String {
        switch self {
        case .triassic: return "252 - 201 Milyon Yıl Önce"
        case .jurassic: return "201 - 145 Milyon Yıl Önce"
        case .cretaceous: return "145 - 66 Milyon Yıl Önce"
        }
    }

    var totalLevels: Int { 4 }
}

class GameManager {
    static let shared = GameManager()

    var selectedCharacter: CharacterType = .boy
    var currentEra: Era = .triassic
    var currentLevel: Int = 1 // 1-4 within current era

    var totalGold: Int = 0
    var levelGold: Int = 0
    var lives: Int = Constants.startingLives
    var extraLifeCounter: Int = 0 // tracks gold toward next extra life

    // Progress: highest unlocked sub-level per era
    var unlockedLevels: [Era: Int] = [
        .triassic: 1,
        .jurassic: 0,
        .cretaceous: 0
    ]

    // Market purchases and usage counts (limited uses per purchase)
    var marketPurchases: Set<String> = []
    var marketUsesRemaining: [String: Int] = [:]

    // Active power-ups for current level
    var hasDoubleCoins: Bool { (marketUsesRemaining["double_coins"] ?? 0) > 0 }
    var hasGoldMagnet: Bool { (marketUsesRemaining["gold_magnet"] ?? 0) > 0 }
    var hasShieldStart: Bool { (marketUsesRemaining["shield_start"] ?? 0) > 0 }
    var hasExtraJump: Bool { (marketUsesRemaining["extra_jump"] ?? 0) > 0 }

    func consumeMarketItem(_ id: String) {
        if let remaining = marketUsesRemaining[id], remaining > 0 {
            marketUsesRemaining[id] = remaining - 1
            if marketUsesRemaining[id] == 0 {
                marketPurchases.remove(id)
            }
            saveProgress()
        }
    }

    private init() {
        loadProgress()
    }

    // MARK: - Gold & Lives

    func collectGold(_ amount: Int = 1) {
        let finalAmount = hasDoubleCoins ? amount * 2 : amount
        levelGold += finalAmount
        totalGold += finalAmount
        extraLifeCounter += finalAmount

        while extraLifeCounter >= Constants.goldForExtraLife {
            extraLifeCounter -= Constants.goldForExtraLife
            lives += 1
        }
    }

    func loseLife() -> Bool {
        lives -= 1
        return lives > 0
    }

    func resetForLevel() {
        levelGold = 0
    }

    func resetForNewGame() {
        lives = Constants.startingLives
        levelGold = 0
        extraLifeCounter = 0
    }

    // MARK: - Level Progression

    func isLevelUnlocked(era: Era, level: Int) -> Bool {
        guard let unlocked = unlockedLevels[era] else { return false }
        return level <= unlocked
    }

    func isEraUnlocked(_ era: Era) -> Bool {
        guard let unlocked = unlockedLevels[era] else { return false }
        return unlocked >= 1
    }

    func completeCurrentLevel() {
        let currentUnlocked = unlockedLevels[currentEra] ?? 0

        if currentLevel >= currentUnlocked {
            if currentLevel < currentEra.totalLevels {
                // Unlock next level in same era
                unlockedLevels[currentEra] = currentLevel + 1
            } else {
                // Completed all levels in this era, unlock next era
                unlockedLevels[currentEra] = currentEra.totalLevels
                if let nextEra = Era(rawValue: currentEra.rawValue + 1) {
                    if (unlockedLevels[nextEra] ?? 0) < 1 {
                        unlockedLevels[nextEra] = 1
                    }
                }
            }
        }

        saveProgress()
    }

    func hasNextLevel() -> Bool {
        if currentLevel < currentEra.totalLevels { return true }
        if let nextEra = Era(rawValue: currentEra.rawValue + 1) {
            return isEraUnlocked(nextEra)
        }
        return false
    }

    func advanceToNextLevel() {
        if currentLevel < currentEra.totalLevels {
            currentLevel += 1
        } else if let nextEra = Era(rawValue: currentEra.rawValue + 1) {
            currentEra = nextEra
            currentLevel = 1
        }
    }

    // MARK: - Persistence

    func saveProgress() {
        SaveManager.shared.saveGameState(self)
    }

    func loadProgress() {
        SaveManager.shared.loadGameState(self)
    }
}
