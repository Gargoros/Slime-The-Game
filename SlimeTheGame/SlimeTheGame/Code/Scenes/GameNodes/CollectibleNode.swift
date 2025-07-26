
import Foundation
import SpriteKit

enum CollectibleTypes: String, CaseIterable {
    case none, blue, green, pink, purple, red
    static var allPlayableCases: [CollectibleTypes] { return [.blue, .green, .pink, .purple, .red] }
    static var random: CollectibleTypes { return allPlayableCases.randomElement() ?? .blue }
}

final class CollectibleNode: SKSpriteNode {
    //MARK: - Properties
    private var collectibleType = CollectibleTypes.none
    private var blueTexture:   [SKTexture]?
    private var greenTexture:  [SKTexture]?
    private var pinkTexture:   [SKTexture]?
    private var purpleTexture: [SKTexture]?
    private var redTexture:    [SKTexture]?
    //MARK: - init
    init(collectibleType: CollectibleTypes) {
        var texture: SKTexture!
        self.collectibleType = collectibleType
        switch collectibleType {
            case .none: break
            case .blue: texture   = SKTexture(imageNamed: "blue_crystal_01")
            case .green: texture  = SKTexture(imageNamed: "green_crystal_01")
            case .pink: texture   = SKTexture(imageNamed: "pink_crystal_01")
            case .purple: texture = SKTexture(imageNamed: "purple_crystal_01")
            case .red: texture    = SKTexture(imageNamed: "red_crystal_01")
        }
        super.init(texture: texture, color: .clear, size: texture.size())
        self.blueTexture   = self.loadTextures(atlas: "Blue_Gems", prefix: "blue_crystal", startAt: 0, stopAt: 3)
        self.greenTexture  = self.loadTextures(atlas: "Green_Gems", prefix: "green_crystal", startAt: 0, stopAt: 3)
        self.pinkTexture   = self.loadTextures(atlas: "Pink_Gems", prefix: "pink_crystal", startAt: 0, stopAt: 3)
        self.purpleTexture = self.loadTextures(atlas: "Purple_Gems", prefix: "purple_crystal", startAt: 0, stopAt: 3)
        self.redTexture    = self.loadTextures(atlas: "Red_Gems", prefix: "red_crystal", startAt: 0, stopAt: 3)
        self.name          = "collect_\(collectibleType)"
        self.anchorPoint   = CGPoint(x: 0.5, y: 0.5)
        self.zPosition     = SceneLayer.collectible.rawValue
        setScale(0.7)
    }
    required init?(coder aDecoder: NSCoder) { fatalError(AppConstants.errors.nodeError) }
    private func setupPhysics() {
        self.physicsBody                     = SKPhysicsBody(texture: texture!, size: texture!.size())
        self.physicsBody?.isDynamic          = true
        self.physicsBody?.affectedByGravity  = false
        self.physicsBody?.categoryBitMask    = PhysicsCategory.gem
        self.physicsBody?.contactTestBitMask = PhysicsCategory.slime | PhysicsCategory.foreground
        self.physicsBody?.collisionBitMask   = PhysicsCategory.none
    }
    //MARK: - states
    private func blueState(){
        guard let blueTexture = blueTexture else { preconditionFailure(AppConstants.errors.animationError) }
        startAnimation(textures: blueTexture, speed: 0.1, name: CollectibleTypes.blue.rawValue, count: 0, resize: false, restore: false)
    }
    private func pinkState(){
        guard let pinkTexture = pinkTexture else { preconditionFailure(AppConstants.errors.animationError) }
        startAnimation(textures: pinkTexture, speed: 0.1, name: CollectibleTypes.pink.rawValue, count: 0, resize: false, restore: false)
    }
    private func greenState(){
        guard let greenTexture = greenTexture else { preconditionFailure(AppConstants.errors.animationError) }
        startAnimation(textures: greenTexture, speed: 0.1, name: CollectibleTypes.green.rawValue, count: 0, resize: false, restore: false)
    }
    private func purpleState(){
        guard let purpleTexture = purpleTexture else { preconditionFailure(AppConstants.errors.animationError) }
        startAnimation(textures: purpleTexture, speed: 0.1, name: CollectibleTypes.purple.rawValue, count: 0, resize: false, restore: false)
    }
    private func redState(){
        guard let redTexture = redTexture else { preconditionFailure(AppConstants.errors.animationError) }
        startAnimation(textures: redTexture, speed: 0.1, name: CollectibleTypes.red.rawValue, count: 0, resize: false, restore: false)
    }
    func runStateAnimation(_ gemType: CollectibleTypes){
        switch gemType {
            case .blue:   blueState()
            case .green:  greenState()
            case .pink:   pinkState()
            case .purple: purpleState()
            case .red:    redState()
            case .none: break
        }
    }
    func dropGem(dropSpeed: TimeInterval, floorLevel: CGFloat, gemType: CollectibleTypes){
        runStateAnimation(gemType)
        setupPhysics()
        let pos            = CGPoint(x: position.x, y: floorLevel)
        let scaleX         = SKAction.scaleX(to: 0.5, duration: 1.0)
        let scaleY         = SKAction.scaleY(to: 0.5, duration: 1.0)
        let scale          = SKAction.group([scaleX, scaleY])
        let appear         = SKAction.fadeAlpha(to: 1.0, duration: 0.25)
        let moveAction     = SKAction.move(to: pos, duration: dropSpeed)
        let actionSequence = SKAction.sequence([appear, scale, moveAction])
        self.scale(to: CGSize(width: 0.25, height: 0.7))
        self.run(actionSequence, withKey: "drop")
    }
    func collected(){
        let removeFromParent = SKAction.removeFromParent()
        self.run(removeFromParent)
    }
    func missed(){
        let removeFromParent = SKAction.removeFromParent()
        self.run(removeFromParent)
    }
}
