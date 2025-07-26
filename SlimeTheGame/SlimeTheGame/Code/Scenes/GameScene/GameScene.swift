
import SpriteKit
import GameplayKit

final class GameScene: SKScene, SKPhysicsContactDelegate, ObservableObject {
    //MARK: - Properties
    internal var gameView: SlimeTheGameView?
    private var sceneFloor             = FloorNode()
    private var slime                  = SlimeNode()
    private var scoreLabel             = SKLabelNode(fontNamed: AppConstants.fonts.regular)
    private var levelLabel             = SKLabelNode(fontNamed: AppConstants.fonts.regular)
    private var movingSlime            = false
    private var lastPosition: CGPoint?
    private var slimeSpeed: CGFloat    = 1.5
    private var numberOfDrop: Int      = 10
    private var dropsExpected: Int     = 10
    private var dropsCollected: Int    = 0
    private var dropSpeed: CGFloat     = 1.0
    private var minDropSpeed: CGFloat  = 0.12
    private var maxDropSpeed: CGFloat  = 1.0
    private var level: Int             = 1 { didSet { levelLabel.text = AppConstants.gameText.level + "\(level)" } }
    private var gameScore: Int         = 0 { didSet { scoreLabel.text = AppConstants.gameText.score + "\(gameScore)" } }
    private var gameInProgress         = false
    //MARK: - Init
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        sceneSetup()
    }
    override func update(_ currentTime: TimeInterval) { checkForRemainingDrops() }
}

//MARK: - Scene setups
extension GameScene {
    private func sceneSetup(){
        physicsWorld.contactDelegate = self
        sceneBackground()
        sceneFloorSetup()
        sceneSlimeSetup()
        sceneLabelsSetup()
        showMessage(AppConstants.gameText.tapText)
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
        sceneFloor.size     = CGSize(width: frame.width, height: frame.height * 0.13)
        addChild(sceneFloor)
    }
    private func sceneSlimeSetup(){
        slime           = SlimeNode()
        slime.position  = CGPoint(x: frame.midX, y: sceneFloor.frame.maxY + slime.frame.height * 0.4)
        slime.zPosition = SceneLayer.slime.rawValue
        slime.setupConstrains(floor: sceneFloor.frame.maxY + slime.frame.height * 0.4)
        addChild(slime)
        slime.idleState()
    }
    private func spawnGem(){
        let gemType   = CollectibleTypes.random
        print("\(gemType.rawValue)")
        let gem       = CollectibleNode(collectibleType: gemType)
        let margin    = gem.size.width * 2
        let dropRange = SKRange(lowerLimit: frame.minX + margin, upperLimit: frame.maxX - margin)
        let randomX   = CGFloat.random(in: dropRange.lowerLimit...dropRange.upperLimit)
        gem.position  = CGPoint(x: randomX, y: frame.maxY - margin)
        addChild(gem)
        gem.dropGem(dropSpeed: TimeInterval(1.0), floorLevel: slime.frame.minY, gemType: gemType)
    }
    private func spawnMultipleGems() {
        hideMessage()
        gameInProgress = true
        
        if gameInProgress == false {
            gameScore  = 0
            level      = 1
        }
        switch level {
            case 1...5: numberOfDrop = level * 10
            case 6: numberOfDrop     = 75
            case 7: numberOfDrop     = 100
            case 8: numberOfDrop     = 150
            case 9: numberOfDrop     = 170
            case 10: numberOfDrop    = 200
            default: numberOfDrop    = 100
        }
        dropsExpected    = numberOfDrop
        dropsCollected   = 0
        dropSpeed        = 1 / (CGFloat(level) + (CGFloat(level) / CGFloat(numberOfDrop)))
        if dropSpeed < minDropSpeed { dropSpeed = minDropSpeed}
        else if dropSpeed > maxDropSpeed { dropSpeed = maxDropSpeed }
        let wait         = SKAction.wait(forDuration: TimeInterval(dropSpeed))
        let spawn        = SKAction.run { [unowned self] in self.spawnGem() }
        let sequence     = SKAction.sequence([wait, spawn])
        let repeatAction = SKAction.repeat(sequence, count: numberOfDrop)
        run(repeatAction, withKey: "gem")
    }
    private func sceneLabelsSetup(){
        //MARK: - Score label
        scoreLabel.name = AppConstants.dataKeys.score.rawValue
        scoreLabel.fontColor = .green
        scoreLabel.fontSize = frame.height * 0.05
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.zPosition = SceneLayer.ui.rawValue
        scoreLabel.position = CGPoint(x: frame.maxX - frame.width * 0.05, y: frame.maxY - frame.height * 0.1)
        scoreLabel.text = AppConstants.gameText.score + "\(gameScore)"
        addChild(scoreLabel)
        //MARK: - Level label
        levelLabel.name = AppConstants.dataKeys.level.rawValue
        levelLabel.fontColor = .green
        levelLabel.fontSize = frame.height * 0.05
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.verticalAlignmentMode = .center
        levelLabel.zPosition = SceneLayer.ui.rawValue
        levelLabel.position = CGPoint(x: frame.minX + frame.width * 0.05, y: frame.maxY - frame.height * 0.1)
        levelLabel.text = AppConstants.gameText.level + "\(level)"
        addChild(levelLabel)
    }
    private func showMessage(_ message: String){
        let messageLabel = SKLabelNode()
        messageLabel.name = AppConstants.dataKeys.message.rawValue
        messageLabel.position = CGPoint(x: frame.midX, y: slime.position.y + frame.height * 0.2)
        messageLabel.zPosition = SceneLayer.ui.rawValue
        messageLabel.numberOfLines = 2
        let paragraph              = NSMutableParagraphStyle()
        paragraph.alignment        = .center
        let attributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: SKColor(red: 251.0/255.0, green: 155.0/255.0, blue: 24.0/255.0, alpha: 1.0),
            .backgroundColor: UIColor.clear,
            .font: UIFont(name: AppConstants.fonts.regular, size: frame.height * 0.07)!,
            .paragraphStyle: paragraph
        ]
        messageLabel.attributedText = NSAttributedString(string: message, attributes: attributes)
        messageLabel.run(SKAction.fadeIn(withDuration: 0.25))
        addChild(messageLabel)
    }
    private func hideMessage(){
        if let messageLabel = childNode(withName: "//message") as? SKLabelNode {
            messageLabel.run(SKAction.sequence([ SKAction.fadeOut(withDuration: 0.25), SKAction.removeFromParent() ]))
        }
    }
}
//MARK: - Scene logic and methods
extension GameScene {
    private func gameOver (){
        showMessage(AppConstants.gameText.gameOver)
        gameInProgress = false
        slime.deathState()
        removeAction(forKey: AppConstants.dataKeys.slime.rawValue)
        enumerateChildNodes(withName: "//collect_*") { node, stop in
            node.removeAction(forKey: AppConstants.dataKeys.drop.rawValue)
            node.physicsBody = nil
        }
    }
    private func resetSlimePosition(){
        let resetPoint      = CGPoint(x: frame.midX, y: slime.position.y)
        let distance        = hypot(resetPoint.x - slime.position.x, 0)
        let calculatedSpeed = TimeInterval(distance / (slimeSpeed * 2) / 255)
        if slime.position.x > frame.midX { slime.moveToPosition(pos: resetPoint, direction: AppConstants.dataKeys.left.rawValue, speed: calculatedSpeed) }
        else { slime.moveToPosition(pos: resetPoint, direction: AppConstants.dataKeys.right.rawValue, speed: calculatedSpeed) }
    }
    private func popRemainingDrops(){
        var i = 0
        enumerateChildNodes(withName: "//collect_*") { node, stop in
            let initialWait      = SKAction.wait(forDuration: 1.0)
            let wait             = SKAction.wait(forDuration: TimeInterval(0.15 * CGFloat(i)))
            let removeFromParent = SKAction.removeFromParent()
            let actionSequence   = SKAction.sequence([initialWait, wait, removeFromParent])
            node.run(actionSequence)
            i += 1
        }
    }
    private func checkForRemainingDrops(){
        if dropsCollected == dropsExpected { nextLevel() }
    }
    private func nextLevel(){
        showMessage(AppConstants.gameText.getReady)
        let wait = SKAction.wait(forDuration: 2.25)
        run(wait, completion: {
            [unowned self] in self.level += 1
            self.spawnMultipleGems()
        })
    }
}
//MARK: - Scene touches
extension GameScene{
    
    private func touchDown(atPoint pos: CGPoint){
        let touchedNode = atPoint(pos)
        if touchedNode.name == AppConstants.dataKeys.slime.rawValue { movingSlime = true }
        let distance = hypot(pos.x - slime.position.x, pos.y - slime.position.y)
        let calculatedSpeed = TimeInterval(distance / slimeSpeed) / 255
        if pos.x < slime.position.x {
            slime.moveToPosition(pos: pos, direction: AppConstants.dataKeys.left.rawValue, speed: calculatedSpeed)
            slime.walkState()
        }
        else {
            slime.moveToPosition(pos: pos, direction: AppConstants.dataKeys.right.rawValue, speed: calculatedSpeed)
            slime.walkState()
        }
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
    private func touchUp(atPoint pos: CGPoint){
        movingSlime = false
        slime.idleState()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches { self.touchDown(atPoint: touch.location(in: self)) }
        if gameInProgress == false {
            spawnMultipleGems()
            return
        }
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
                dropsCollected += 1
                gameScore += level
                checkForRemainingDrops()
            }
        }
        if collision == PhysicsCategory.foreground | PhysicsCategory.gem {
            let body = contact.bodyA.categoryBitMask == PhysicsCategory.gem ? contact.bodyA.node : contact.bodyB.node
            if let sprite = body as? CollectibleNode {
                sprite.missed()
                gameOver()
            }
        }
    }
    
}
