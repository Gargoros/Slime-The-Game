
import Foundation
import SpriteKit

enum SlimeAnimationType: String {
    case idle
    case walk
    case fastWalk
    case jump
    case death
}

final class SlimeNode: SKSpriteNode {
    private var idleTexture:     [SKTexture]?
    private var walkTexture:     [SKTexture]?
    private var jumpTexture:     [SKTexture]?
    private var fastWalkTexture: [SKTexture]?
    private var deathTexture:    [SKTexture]?
    
    init() {
        let texture = SKTexture(imageNamed: "slime_idle_01")
        super.init(texture: texture, color: .clear, size: texture.size())
        self.idleTexture     = self.loadTextures(atlas: "Slime_Idle", prefix: "slime_idle", startAt: 0, stopAt: 6)
        self.walkTexture     = self.loadTextures(atlas: "Slime_Walk", prefix: "slime_walk", startAt: 0, stopAt: 10)
        self.jumpTexture     = self.loadTextures(atlas: "Slime_Jump", prefix: "slime_jump", startAt: 0, stopAt: 19)
        self.fastWalkTexture = self.loadTextures(atlas: "Slime_Fast_Walk", prefix: "slime_fast_walk", startAt: 0, stopAt: 10)
        self.deathTexture    = self.loadTextures(atlas: "Slime_Death", prefix: "slime_death", startAt: 0, stopAt: 13)
        self.name            = "slime"
        self.setScale(1)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError(AppConstants.errors.nodeError)
    }
    func setupConstrains(floor: CGFloat){
        let range          = SKRange(lowerLimit: floor, upperLimit: floor)
        let lockToPlatform = SKConstraint.positionY(range)
        constraints        = [ lockToPlatform ]
    }
    //MARK: - states
    func idleState(){
        guard let idleTexture = idleTexture else { preconditionFailure(AppConstants.errors.animationError) }
        startAnimation(
            textures: idleTexture,
            speed: 0.1,
            name: SlimeAnimationType.idle.rawValue,
            count: 0,
            resize: true,
            restore: true
        )
    }
    func walkState(){
        guard let walkTexture = walkTexture else { preconditionFailure(AppConstants.errors.animationError) }
        startAnimation(
            textures: walkTexture,
            speed: 0.1,
            name: SlimeAnimationType.walk.rawValue,
            count: 0,
            resize: true,
            restore: true
        )
    }
    func jumpState(){
        guard let jumpTexture = jumpTexture else { preconditionFailure(AppConstants.errors.animationError) }
        startAnimation(
            textures: jumpTexture,
            speed: 0.1,
            name: SlimeAnimationType.jump.rawValue,
            count: 0,
            resize: true,
            restore: true
        )
    }
    func fastWalkState(){
        guard let fastWalkTexture = fastWalkTexture else { preconditionFailure(AppConstants.errors.animationError) }
        startAnimation(
            textures: fastWalkTexture,
            speed: 0.1,
            name: SlimeAnimationType.fastWalk.rawValue,
            count: 0,
            resize: true,
            restore: true
        )
    }
    func deathState(){
        guard let deathTexture = deathTexture else { preconditionFailure(AppConstants.errors.animationError) }
        startAnimation(
            textures: deathTexture,
            speed: 0.1,
            name: SlimeAnimationType.death.rawValue,
            count: 0,
            resize: true,
            restore: true
        )
    }
    
    func moveToPosition(pos: CGPoint, direction: String, speed: TimeInterval){
        switch direction {
            case "Left": xScale = -abs(xScale)
            default: xScale = abs(xScale)
        }
        let moveAction = SKAction.move(to: pos, duration: speed)
        run(moveAction)
    }
}
