
import Foundation
import SpriteKit

enum SlimeAnimationType: String {
    case idle, walk, death
}

final class SlimeNode: SKSpriteNode {
    //MARK: - Properties
    private var idleTexture:     [SKTexture]?
    private var walkTexture:     [SKTexture]?
    private var deathTexture:    [SKTexture]?
    //MARK: - Init
    init() {
        let texture          = SKTexture(imageNamed: AppConstants.imageNames.startSlime)
        super.init(texture: texture, color: .clear, size: texture.size())
        self.idleTexture     = self.loadTextures(atlas: AppConstants.atlasNames.idleAtlas, prefix: AppConstants.atlasPrefixes.idlePrefix, startAt: 0, stopAt: 6)
        self.walkTexture     = self.loadTextures(atlas: AppConstants.atlasNames.walkAtlas, prefix: AppConstants.atlasPrefixes.walkPrefix, startAt: 0, stopAt: 10)
        self.deathTexture    = self.loadTextures(atlas: AppConstants.atlasNames.deathAtlas, prefix: AppConstants.atlasPrefixes.deathPrefix, startAt: 0, stopAt: 13)
        self.name            = AppConstants.dataKeys.slime.rawValue
        self.anchorPoint     = CGPoint(x: 0.5, y: 0.5)
        self.setScale(1)
        setupPhysics()
    }
    required init?(coder aDecoder: NSCoder) { fatalError(AppConstants.errors.nodeError) }
    func setupConstrains(floor: CGFloat){
        let range          = SKRange(lowerLimit: floor, upperLimit: floor)
        let lockToPlatform = SKConstraint.positionY(range)
        constraints        = [ lockToPlatform ]
    }
    private func setupPhysics(){
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size)
        self.physicsBody?.isDynamic          = true
        self.physicsBody?.affectedByGravity  = false
        self.physicsBody?.categoryBitMask    = PhysicsCategory.slime
        self.physicsBody?.contactTestBitMask = PhysicsCategory.gem
        self.physicsBody?.collisionBitMask   = PhysicsCategory.none
    }
    //MARK: - states
    func idleState(){
        guard let idleTexture = idleTexture else { preconditionFailure(AppConstants.errors.animationError) }
        removeAction(forKey: SlimeAnimationType.death.rawValue)
        removeAction(forKey: SlimeAnimationType.walk.rawValue)
        startAnimation(textures: idleTexture, speed: 0.1, name: SlimeAnimationType.idle.rawValue, count: 0, resize: true, restore: true)
    }
    func walkState(){
        guard let walkTexture = walkTexture else { preconditionFailure(AppConstants.errors.animationError) }
        removeAction(forKey: SlimeAnimationType.idle.rawValue)
        startAnimation(textures: walkTexture, speed: 0.1, name: SlimeAnimationType.walk.rawValue, count: 0, resize: true, restore: true)
    }
    func deathState(){
        guard let deathTexture = deathTexture else { preconditionFailure(AppConstants.errors.animationError) }
        removeAction(forKey: SlimeAnimationType.walk.rawValue)
        removeAction(forKey: SlimeAnimationType.idle.rawValue)
        startAnimation(textures: deathTexture, speed: 0.1, name: SlimeAnimationType.death.rawValue, count: 1, resize: true, restore: true)
    }
    func moveToPosition(pos: CGPoint, direction: String, speed: TimeInterval){
        switch direction {
            case AppConstants.dataKeys.left.rawValue: xScale = -abs(xScale)
            default: xScale = abs(xScale)
        }
        let newPos              = CGPoint(x: pos.x, y: position.y)
        let moveAction          = SKAction.move(to: newPos, duration: speed)
        run(moveAction)
    }
}
