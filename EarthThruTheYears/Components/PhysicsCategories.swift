import Foundation

enum PhysicsCategory {
    static let none:      UInt32 = 0
    static let player:    UInt32 = 0x1 << 0   // 1
    static let ground:    UInt32 = 0x1 << 1   // 2
    static let enemy:     UInt32 = 0x1 << 2   // 4
    static let coin:      UInt32 = 0x1 << 3   // 8
    static let powerUp:   UInt32 = 0x1 << 4   // 16
    static let robot:     UInt32 = 0x1 << 5   // 32
    static let boundary:  UInt32 = 0x1 << 6   // 64
    static let platform:  UInt32 = 0x1 << 7   // 128
    static let endFlag:   UInt32 = 0x1 << 8   // 256
}
