
import Foundation
import SpriteKit

enum SlimeAnimationType: String {
    case idle
}

final class SlimeNode: SKSpriteNode {
    private var idleTexture: [SKTexture]?
    
    init() {
        let texture = SKTexture(imageNamed: "slime_idle_01")
        super.init(texture: texture, color: .clear, size: texture.size())
        self.idleTexture = self.loadTextures(atlas: "Slime_Idle", prefix: "slime_idle", startAt: 0, stopAt: 6)
        self.name = "slime"
        self.setScale(1)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func idleState(){
        guard let idleTexture = idleTexture else { preconditionFailure("Could not find textures!") }
        startAnimation(
            textures: idleTexture,
            speed: 0.1,
            name: SlimeAnimationType.idle.rawValue,
            count: 0,
            resize: true,
            restore: true
        )
    }
}
