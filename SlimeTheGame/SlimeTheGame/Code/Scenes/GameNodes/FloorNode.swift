
import SpriteKit

final class FloorNode: SKSpriteNode {
    private let floorTexture = SKTexture(imageNamed: "slimeFloor")
    
    init() {
        super.init(texture: floorTexture, color: .clear, size: floorTexture.size())
        floorSetup()
        floorPhysicsBodySetup()
    }
    required init?(coder aDecoder: NSCoder) { fatalError(AppConstants.errors.nodeError) }
    
    private func floorSetup(){ self.zPosition = SceneLayer.floor.rawValue }
    private func floorPhysicsBodySetup(){
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = false
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.categoryBitMask = PhysicsCategory.foreground
        self.physicsBody?.contactTestBitMask = PhysicsCategory.gem
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
    }
}
