
import SpriteKit
import GameplayKit

final class GameScene: SKScene {
    //MARK: - Properties
    private var sceneFloor: SKSpriteNode!
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
        let slime = SlimeNode()
        slime.position = CGPoint(x: frame.midX, y: sceneFloor.frame.maxY)
        slime.zPosition = SceneLayer.slime.rawValue
        addChild(slime)
        slime.idleState()
    }
}
