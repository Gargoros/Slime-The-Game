
import Foundation

enum SceneLayer: CGFloat {
    case background
    case floorBG
    case emptyfloor
    case floor
    case slime
    case collectible
    case ui
}

enum PhysicsCategory {
    static let none: UInt32       = 0x1 << 0
    static let slime: UInt32      = 0x1 << 1
    static let gem: UInt32        = 0x1 << 2
    static let foreground: UInt32 = 0x1 << 3
    
}

