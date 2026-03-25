import Foundation

class SaveManager {
    static let shared = SaveManager()
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let totalGold = "totalGold"
        static let selectedCharacter = "selectedCharacter"
        static let unlockedTriassic = "unlockedTriassic"
        static let unlockedJurassic = "unlockedJurassic"
        static let unlockedCretaceous = "unlockedCretaceous"
        static let marketPurchases = "marketPurchases"
        static let soundEnabled = "soundEnabled"
        static let musicEnabled = "musicEnabled"
        static let extraLifeCounter = "extraLifeCounter"
    }

    private init() {}

    // MARK: - Game State

    func saveGameState(_ manager: GameManager) {
        defaults.set(manager.totalGold, forKey: Keys.totalGold)
        defaults.set(manager.selectedCharacter.rawValue, forKey: Keys.selectedCharacter)
        defaults.set(manager.unlockedLevels[.triassic] ?? 1, forKey: Keys.unlockedTriassic)
        defaults.set(manager.unlockedLevels[.jurassic] ?? 0, forKey: Keys.unlockedJurassic)
        defaults.set(manager.unlockedLevels[.cretaceous] ?? 0, forKey: Keys.unlockedCretaceous)
        defaults.set(Array(manager.marketPurchases), forKey: Keys.marketPurchases)
        defaults.set(manager.extraLifeCounter, forKey: Keys.extraLifeCounter)
        defaults.synchronize()
    }

    func loadGameState(_ manager: GameManager) {
        manager.totalGold = defaults.integer(forKey: Keys.totalGold)
        manager.extraLifeCounter = defaults.integer(forKey: Keys.extraLifeCounter)

        if let charRaw = defaults.string(forKey: Keys.selectedCharacter),
           let char = CharacterType(rawValue: charRaw) {
            manager.selectedCharacter = char
        }

        let tri = defaults.object(forKey: Keys.unlockedTriassic) as? Int ?? 1
        let jur = defaults.object(forKey: Keys.unlockedJurassic) as? Int ?? 0
        let cre = defaults.object(forKey: Keys.unlockedCretaceous) as? Int ?? 0
        manager.unlockedLevels = [
            .triassic: tri,
            .jurassic: jur,
            .cretaceous: cre
        ]

        if let purchases = defaults.array(forKey: Keys.marketPurchases) as? [String] {
            manager.marketPurchases = Set(purchases)
        }
    }

    // MARK: - Options

    var soundEnabled: Bool {
        get { defaults.object(forKey: Keys.soundEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Keys.soundEnabled) }
    }

    var musicEnabled: Bool {
        get { defaults.object(forKey: Keys.musicEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Keys.musicEnabled) }
    }

    func save() {
        defaults.synchronize()
    }
}
