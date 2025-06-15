
import SpriteKit
import GameplayKit

final class GameScene: SKScene, SKPhysicsContactDelegate, ObservableObject {
    //MARK: - Properties
    internal var gameView: SlimeTheGameView?
    private var sceneFloor = FloorNode()
    private var slime                  = SlimeNode()
    private var movingSlime            = false
    private var lastPosition: CGPoint?
    private var slimeSpeed: CGFloat    = 1.5
    private var level: Int             = 1
    private var numberOfDrop: Int      = 10
    private var dropSpeed: CGFloat     = 1.0
    private var minDropSpeed: CGFloat  = 0.12
    private var maxDropSpeed: CGFloat  = 1.0
    //MARK: - Init
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        sceneSetup()
    }
}

//MARK: - Scene setups
extension GameScene {
    private func sceneSetup(){
        physicsWorld.contactDelegate = self
        sceneBackground()
        sceneFloorSetup()
        sceneSlimeSetup()
        spawnMultipleGems()
    }
    private func sceneBackground(){
        let backgroundImageNames   = ["slimeBG_01", "slimeBG_02", "slimeBG_03", "slimeBG_04"]
        for imageName in backgroundImageNames {
            let background         = SKSpriteNode(imageNamed: imageName)
            background.anchorPoint = CGPoint(x: 0.0, y: 0.0)
            background.position    = CGPoint(x: 0.0, y: 0.0)
            background.size        = CGSize(width: frame.width, height: frame.height)
            background.zPosition   = SceneLayer.background.rawValue
            addChild(background)
        }
    }
    private func sceneFloorSetup(){
        sceneFloor.position = CGPoint(x: frame.midX, y: frame.minY)
        sceneFloor.size = CGSize(width: frame.width, height: frame.height * 0.13)
        addChild(sceneFloor)
    }
    private func sceneSlimeSetup(){
        slime = SlimeNode()
        slime.position = CGPoint(x: frame.midX, y: sceneFloor.frame.maxY)
        slime.zPosition = SceneLayer.slime.rawValue
        slime.setupConstrains(floor: sceneFloor.frame.maxY + slime.frame.height * 0.4)
        addChild(slime)
        slime.idleState()
    }
    private func spawnGem(){
        let gemType = CollectibleTypes.random
        print("\(gemType.rawValue)")
        let gem = CollectibleNode(collectibleType: gemType)
        let margin = gem.size.width * 2
        let dropRange = SKRange(lowerLimit: frame.minX + margin, upperLimit: frame.maxX - margin)
        let randomX = CGFloat.random(in: dropRange.lowerLimit...dropRange.upperLimit)
        gem.position = CGPoint(x: randomX, y: frame.maxY - margin)
        addChild(gem)
        gem.dropGem(dropSpeed: TimeInterval(1.0), floorLevel: slime.frame.minY, gemType: gemType)
    }
    private func spawnMultipleGems() {
        switch level {
            case 1...5: numberOfDrop = level * 10
            case 6: numberOfDrop     = 75
            case 7: numberOfDrop     = 100
            case 8: numberOfDrop     = 150
            case 9: numberOfDrop     = 170
            case 10: numberOfDrop    = 200
            default: numberOfDrop    = 100
        }
        dropSpeed = 1 / (CGFloat(level) + (CGFloat(level) / CGFloat(numberOfDrop)))
        if dropSpeed < minDropSpeed { dropSpeed = minDropSpeed}
        else if dropSpeed > maxDropSpeed { dropSpeed = maxDropSpeed }
        let wait = SKAction.wait(forDuration: TimeInterval(dropSpeed))
        let spawn = SKAction.run { [unowned self] in self.spawnGem() }
        let sequence = SKAction.sequence([wait, spawn])
        let repeatAction = SKAction.repeat(sequence, count: numberOfDrop)
        run(repeatAction, withKey: "gem")
    }
}
//MARK: - Scene touches
extension GameScene{
    
    private func touchDown(atPoint pos: CGPoint){
        let touchedNode = atPoint(pos)
        if touchedNode.name == "slime" { movingSlime = true }
        let distance = hypot(pos.x - slime.position.x, pos.y - slime.position.y)
        let calculatedSpeed = TimeInterval(distance / slimeSpeed) / 255
        if pos.x < slime.position.x { slime.moveToPosition(pos: pos, direction: "Left", speed: calculatedSpeed) }
        else { slime.moveToPosition(pos: pos, direction: "Right", speed: calculatedSpeed) }
    }
    private func touchMoved(toPoint pos: CGPoint){
        if movingSlime == true {
            let newPos = CGPoint(x: pos.x, y: slime.position.y)
            slime.position = newPos
            let recordedPosition = lastPosition ?? slime.position
            if recordedPosition.x > newPos.x { slime.xScale = -abs(xScale) }
            else { slime.xScale = abs(xScale) }
            lastPosition = newPos
        }
    }
    private func touchUp(atPoint pos: CGPoint){ movingSlime = false }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches { self.touchDown(atPoint: touch.location(in: self)) }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches { self.touchMoved(toPoint: touch.location(in: self)) }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches { self.touchUp(atPoint: touch.location(in: self)) }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches { self.touchUp(atPoint: touch.location(in: self)) }
    }
}
//MARK: - Scene contacts
extension GameScene {
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == PhysicsCategory.slime | PhysicsCategory.gem {
            let body = contact.bodyA.categoryBitMask == PhysicsCategory.gem ? contact.bodyA.node : contact.bodyB.node
            if let sprite = body as? CollectibleNode {
                sprite.collected()
            }
        }
        if collision == PhysicsCategory.foreground | PhysicsCategory.gem {
            let body = contact.bodyA.categoryBitMask == PhysicsCategory.gem ? contact.bodyA.node : contact.bodyB.node
            if let sprite = body as? CollectibleNode {
                sprite.missed()
            }
        }
    }
    
}
