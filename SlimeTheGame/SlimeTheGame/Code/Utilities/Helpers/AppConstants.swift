
import Foundation

enum AppConstants {
    //MARK: - Errors
    enum errors {
        static let nodeError       = "init(coder:) has not been implemented"
        static let animationError  = "Could not find textures!"
    }
    //MARK: - Fonts
    enum font {
        static let regular: String = "Nosifer-Regular"
    }
    enum fonts {
        static let regular        = "Nosifer-Regular"
    }
    enum gameText {
        static let tapText        = "Tap to start game"
        static let gameOver       = "Game Over\nTap to try again"
        static let getReady       = "Get Ready!"
        static let level          = "Level: "
        static let score          = "Score: "
    }
    enum soundNames {
        static let bgSound        = "slimeBGSound"
        static let collectSound   = "slimeCollect"
        static let missSound      = "slimeCreate"
        static let gameOverSound  = "slimeGameOver"
        static let tapSound       = "slimeTheGameTapSound"
        static let forestSound    = "slimeForestSound"
    }
    enum imageNames {
        static let floorBG        = "floorBG_01"
        static let floorImage     = "slimeFloor"
        static let startSlime     = "slime_idle_01"
        static let blueCrystal    = "blue_crystal_01"
        static let greenCrystal   = "green_crystal_01"
        static let pinkCrystal    = "pink_crystal_01"
        static let purpleCrystal  = "purple_crystal_01"
        static let redCrystal     = "red_crystal_01"
    }
    enum atlasNames {
        static let idleAtlas      = "Slime_Idle"
        static let walkAtlas      = "Slime_Walk"
        static let deathAtlas     = "Slime_Death"
        
        static let blueAtlas      = "Blue_Gems"
        static let greenAtlas     = "Green_Gems"
        static let pinkAtlas      = "Pink_Gems"
        static let purpleAtlas    = "Purple_Gems"
        static let redAtlas       = "Red_Gems"
    }
    enum atlasPrefixes {
        static let idlePrefix     = "slime_idle"
        static let walkPrefix     = "slime_walk"
        static let deathPrefix    = "slime_death"
        static let bluePrefix     = "blue_crystal"
        static let greenPrefix    = "green_crystal"
        static let pinkPrefix     = "pink_crystal"
        static let purplePrefix   = "purple_crystal"
        static let redPrefix      = "red_crystal"
    }
    enum nodeNames {
        static let gemName        = "collect_"
        static let allGameName    = "//collect_*"
        static let message        = "//message"
    }
    
    enum dataKeys: String {
        case floorBG
        case score
        case level
        case message
        case slime
        case gem
        case drop
        case left
        case right
    }
    static let backgroundImageNames   = ["slimeBG_01", "slimeBG_02", "slimeBG_03", "slimeBG_04"]
}
