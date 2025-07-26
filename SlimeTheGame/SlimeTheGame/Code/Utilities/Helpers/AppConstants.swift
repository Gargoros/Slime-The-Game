
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
    enum dataKeys: String {
        case score
        case level
        case message
        case slime
        case drop
        case left
        case right
    }
}
