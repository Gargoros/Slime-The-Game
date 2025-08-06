
import SpriteKit

final class FloorNode: SKSpriteNode {
    //MARK: - Properties
    private let floorTexture = SKTexture(imageNamed: AppConstants.imageNames.floorImage)
    //MARK: - Init
    init(sceneSize: CGRect) {
        super.init(texture: floorTexture, color: .clear, size: CGSize(width: sceneSize.width, height: sceneSize.height * 0.15))
        floorSetup()
        floorPhysicsBodySetup(sceneSize: sceneSize)
    }
    required init?(coder aDecoder: NSCoder) { fatalError(AppConstants.errors.nodeError) }
    private func floorSetup(){ self.zPosition = SceneLayer.floor.rawValue }
    private func floorPhysicsBodySetup(sceneSize: CGRect){
        self.physicsBody                     = SKPhysicsBody(rectangleOf: CGSize(width: sceneSize.width, height: sceneSize.height * 0.15))
        self.physicsBody?.affectedByGravity  = false
        self.physicsBody?.isDynamic          = false
        self.physicsBody?.restitution        = 0.0
        self.physicsBody?.categoryBitMask    = PhysicsCategory.foreground
        self.physicsBody?.contactTestBitMask = PhysicsCategory.gem
        self.physicsBody?.collisionBitMask   = PhysicsCategory.none
    }
}
