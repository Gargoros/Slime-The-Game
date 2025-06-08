
import SpriteKit
import GameplayKit

final class GameScene: SKScene {
    //MARK: - Properties
    private var sceneFloor: SKSpriteNode!
    private var slime = SlimeNode()
    private var slimeSpeed: CGFloat = 1.5
    //MARK: - Init
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        sceneSetup()
    }
}

//MARK: - Scene setups
extension GameScene {
    private func sceneSetup(){
        sceneBackground()
        sceneFloorSetup()
        sceneSlimeSetup()
    }
    private func sceneBackground(){
        let backgroundImageNames = ["slimeBG_01", "slimeBG_02", "slimeBG_03", "slimeBG_04"]
        
        for imageName in backgroundImageNames {
            let background = SKSpriteNode(imageNamed: imageName)
            background.anchorPoint = CGPoint(x: 0.0, y: 0.0)
            background.position = CGPoint(x: 0.0, y: 0.0)
            background.size = CGSize(width: frame.width, height: frame.height)
            background.zPosition = SceneLayer.background.rawValue
            addChild(background)
        }
    }
    private func sceneFloorSetup(){
        sceneFloor = SKSpriteNode(imageNamed: "slimeFloor")
        sceneFloor.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        sceneFloor.position = CGPoint(x: 0.0, y: 0.0)
        sceneFloor.size = CGSize(width: frame.width, height: frame.height * 0.1)
        sceneFloor.zPosition = SceneLayer.floor.rawValue
        addChild(sceneFloor)
    }
    private func sceneSlimeSetup(){
        slime = SlimeNode()
        slime.position = CGPoint(x: frame.midX, y: sceneFloor.frame.maxY)
        slime.zPosition = SceneLayer.slime.rawValue
        slime.setupConstrains(floor: sceneFloor.frame.maxY)
        addChild(slime)
        slime.deathState()
    }
}
//MARK: - Scene touches
extension GameScene{
    func touchDown(atPoint pos: CGPoint){
        let distance = hypot(pos.x - slime.position.x, pos.y - slime.position.y)
        let calculatedSpeed = TimeInterval(distance / slimeSpeed) / 255
        if pos.x < slime.position.x { slime.moveToPosition(pos: pos, direction: "Left", speed: calculatedSpeed) }
        else { slime.moveToPosition(pos: pos, direction: "Right", speed: calculatedSpeed) }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches { self.touchDown(atPoint: touch.location(in: self)) }
    }
}
