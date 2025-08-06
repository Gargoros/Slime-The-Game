
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
    private let collectSound  = SKAction.playSoundFileNamed(AppConstants.soundNames.collectSound, waitForCompletion: false)
    private let missSound     = SKAction.playSoundFileNamed(AppConstants.soundNames.missSound, waitForCompletion: false)
    //MARK: - init
    init(collectibleType: CollectibleTypes) {
        var texture: SKTexture!
        self.collectibleType = collectibleType
        switch collectibleType {
            case .none: break
            case .blue: texture   = SKTexture(imageNamed: AppConstants.imageNames.blueCrystal)
            case .green: texture  = SKTexture(imageNamed: AppConstants.imageNames.greenCrystal)
            case .pink: texture   = SKTexture(imageNamed: AppConstants.imageNames.pinkCrystal)
            case .purple: texture = SKTexture(imageNamed: AppConstants.imageNames.purpleCrystal)
            case .red: texture    = SKTexture(imageNamed: AppConstants.imageNames.redCrystal)
        }
        super.init(texture: texture, color: .clear, size: texture.size())
        self.blueTexture   = self.loadTextures(atlas: AppConstants.atlasNames.blueAtlas, prefix: AppConstants.atlasPrefixes.bluePrefix , startAt: 0, stopAt: 3)
        self.greenTexture  = self.loadTextures(atlas: AppConstants.atlasNames.greenAtlas, prefix: AppConstants.atlasPrefixes.greenPrefix, startAt: 0, stopAt: 3)
        self.pinkTexture   = self.loadTextures(atlas: AppConstants.atlasNames.pinkAtlas, prefix: AppConstants.atlasPrefixes.pinkPrefix, startAt: 0, stopAt: 3)
        self.purpleTexture = self.loadTextures(atlas: AppConstants.atlasNames.purpleAtlas, prefix: AppConstants.atlasPrefixes.purplePrefix, startAt: 0, stopAt: 3)
        self.redTexture    = self.loadTextures(atlas: AppConstants.atlasNames.redAtlas, prefix: AppConstants.atlasPrefixes.redPrefix, startAt: 0, stopAt: 3)
        self.name          = AppConstants.nodeNames.gemName + "\(collectibleType)"
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
        self.run(actionSequence, withKey: AppConstants.dataKeys.drop.rawValue)
        collectedEffect()
    }
    func collected(){
        let removeFromParent = SKAction.removeFromParent()
        let actionGroup = SKAction.group([collectSound, removeFromParent])
        self.run(actionGroup)

    }
    func missed(){
        let move = SKAction.moveBy(x: 0, y: -size.height / 1.5, duration: 0.0)
        let splatX = SKAction.scaleX(to: 1.5, duration: 0.0)
        let splatY = SKAction.scaleY(to: 0.5, duration: 0.0)
        let actionGroup = SKAction.group([missSound, move, splatX, splatY])
        self.run(actionGroup)
    }
    func collectedEffect(){
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        addChild(effectNode)
        effectNode.addChild(SKSpriteNode(texture: texture))
        effectNode.filter = CIFilter(name: AppConstants.filterName.giFilterName, parameters:  [AppConstants.dataKeys.inputRadius.rawValue: 40.0])
    }
}
