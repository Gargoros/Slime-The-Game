
import SpriteKit
import GameplayKit
import AVFoundation

final class GameScene: SKScene, SKPhysicsContactDelegate, ObservableObject {
    //MARK: - Properties
    internal var gameView: SlimeTheGameView?
    private var sceneFloor: FloorNode!
    private var slime                     = SlimeNode()
    private var scoreLabel                = SKLabelNode(fontNamed: AppConstants.font.regular)
    private var levelLabel                = SKLabelNode(fontNamed: AppConstants.font.regular)
    private var movingSlime               = false
    private var lastPosition: CGPoint?
    private var slimeSpeed: CGFloat       = 1.5
    private var numberOfDrop: Int         = 10
    private var prevDropLocation: CGFloat = 0.0
    private var dropsExpected: Int        = 10
    private var dropsCollected: Int       = 0
    private var dropSpeed: CGFloat        = 1.0
    private var minDropSpeed: CGFloat     = 0.12
    private var maxDropSpeed: CGFloat     = 1.0
    private var level: Int                = 1 { didSet { levelLabel.text = AppConstants.gameText.level + "\(level)" } }
    private var gameScore: Int            = 0 { didSet { scoreLabel.text = AppConstants.gameText.score + "\(gameScore)" } }
    private var gameInProgress            = false
    private var lastSoundSetting: Bool    = SlimeAppUserDefaults.isSound
    private var bgAudioNode               = SKAudioNode()
    private var forestAudioNode           = SKAudioNode()
    private let gameOverSound = SKAction.playSoundFileNamed(AppConstants.soundNames.gameOverSound, waitForCompletion: false)
    private let tapSound      = SKAction.playSoundFileNamed(AppConstants.soundNames.tapSound, waitForCompletion: false)
    //MARK: - Init
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        sceneSetup()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    override func update(_ currentTime: TimeInterval) {
        checkForRemainingDrops()
        checkSoundSetting()
    }
    deinit { NotificationCenter.default.removeObserver(self) }
    @objc private func appWillResignActive() {
        gamePaused()
        bgAudioNode.run(SKAction.pause())
        forestAudioNode.run(SKAction.pause())
    }
    @objc private func appDidBecomeActive() {
        gameResume()
        if SlimeAppUserDefaults.isSound {
            bgAudioNode.run(SKAction.play())
            forestAudioNode.run(SKAction.play())
        }
    }
}
//MARK: - Scene setups
extension GameScene {
    private func sceneSetup(){
        physicsWorld.contactDelegate = self
        audioEngine.mainMixerNode.outputVolume = 0.0
        sceneBackground()
        sceneFloorBGSetup()
        sceneFloorSetup()
        sceneLabelsSetup()
        showMessage(AppConstants.gameText.tapText)
        playBackgroundSound()
    }
    private func sceneBackground(){
        let backgroundImageNames   = AppConstants.backgroundImageNames
        for imageName in backgroundImageNames {
            let background         = SKSpriteNode(imageNamed: imageName)
            background.position    = CGPoint(x: frame.midX, y: frame.midY)
            background.size        = CGSize(width: frame.width, height: frame.height * 1.5)
            background.zPosition   = SceneLayer.background.rawValue
            background.name        = AppConstants.dataKeys.background.rawValue
            addChild(background)
        }
    }
    private func sceneFloorBGSetup(){
        let floorBG       = SKNode()
        floorBG.name      = AppConstants.dataKeys.floorBG.rawValue
        floorBG.zPosition = SceneLayer.floorBG.rawValue
        floorBG.position  =  CGPoint(x: frame.minX, y: frame.minY - frame.height * 0.03)
        floorBG.setupScrollingView(imageName: AppConstants.imageNames.floorBG, layer: SceneLayer.floorBG, blocks: 3, speed: 30.0, emitterNamed: AppConstants.particleNames.floorEffect)
        addChild(floorBG)
    }
    private func sceneFloorSetup(){
        sceneFloor = FloorNode(sceneSize: frame)
        sceneFloor.position = CGPoint(x: frame.midX, y: frame.minY)
        addChild(sceneFloor)
    }
    private func sceneSlimeSetup(){
        childNode(withName: AppConstants.dataKeys.slime.rawValue)?.removeFromParent()
        slime           = SlimeNode()
        slime.position  = CGPoint(x: frame.midX, y: sceneFloor.frame.maxY + slime.frame.height * 0.4)
        slime.zPosition = SceneLayer.slime.rawValue
        slime.setupConstrains(floor: sceneFloor.frame.maxY + slime.frame.height * 0.4)
        addChild(slime)
        slime.idleState()
        chompLabelSetup()
    }
    private func spawnGem(){
        let gemType   = CollectibleTypes.random
        let gem       = CollectibleNode(collectibleType: gemType)
        let margin    = gem.size.width * 2
        let dropRange = SKRange(lowerLimit: frame.minX + margin, upperLimit: frame.maxX - margin)
        var randomX   = CGFloat.random(in: dropRange.lowerLimit...dropRange.upperLimit)
        enhanceDropMovement(margin: margin, randomX: &randomX)
        addNumberLabel(to: gem)
        gem.position  = CGPoint(x: randomX, y: frame.maxY - margin)
        addChild(gem)
        gem.dropGem(dropSpeed: TimeInterval(1.0), floorLevel: slime.frame.minY, gemType: gemType)
        
    }
    private func enhanceDropMovement(margin: CGFloat, randomX: inout CGFloat) {
        let randomModifier = SKRange(lowerLimit: 50 + CGFloat(level), upperLimit: 60 * CGFloat(level))
        var modifier = CGFloat.random(in: randomModifier.lowerLimit...randomModifier.upperLimit)
        if modifier > 400 { modifier = 400 }
        if prevDropLocation == 0.0 { prevDropLocation = randomX }
        if prevDropLocation < randomX { randomX = prevDropLocation + modifier }
        else { randomX = prevDropLocation - modifier }
        if randomX <= (frame.minX + margin) { randomX = frame.minX + margin }
        else if randomX >= (frame.maxX - margin) { randomX = frame.maxX - margin }
        prevDropLocation = randomX
    }
    private func addNumberLabel(to gem: SKSpriteNode) {
        let xLabel = SKLabelNode()
        xLabel.name = AppConstants.dataKeys.gemNumber.rawValue
        xLabel.fontName = AppConstants.font.regular
        xLabel.fontColor = .appOrange
        xLabel.fontSize = frame.height * 0.06
        xLabel.text = "\(numberOfDrop)"
        xLabel.position = CGPoint(x: 0, y: gem.frame.height)
        gem.addChild(xLabel)
        numberOfDrop -= 1
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
        dropsCollected   = 0
        dropsExpected    = numberOfDrop
        dropSpeed        = 1 / (CGFloat(level) + (CGFloat(level) / CGFloat(numberOfDrop)))
        if dropSpeed < minDropSpeed { dropSpeed = minDropSpeed}
        else if dropSpeed > maxDropSpeed { dropSpeed = maxDropSpeed }
        let wait         = SKAction.wait(forDuration: TimeInterval(dropSpeed))
        let spawn        = SKAction.run { [unowned self] in self.spawnGem() }
        let sequence     = SKAction.sequence([wait, spawn])
        let repeatAction = SKAction.repeat(sequence, count: numberOfDrop)
        run(repeatAction, withKey: AppConstants.dataKeys.gem.rawValue)
    }
    private func sceneLabelsSetup(){
        //MARK: - Score label
        scoreLabel.name = AppConstants.dataKeys.score.rawValue
        scoreLabel.fontColor = .appGreen
        scoreLabel.fontSize = frame.height * 0.05
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.zPosition = SceneLayer.ui.rawValue
        scoreLabel.position = CGPoint(x: frame.maxX - frame.width * 0.05, y: frame.maxY - frame.height * 0.1)
        scoreLabel.text = AppConstants.gameText.score + "\(gameScore)"
        addChild(scoreLabel)
        //MARK: - Level label
        levelLabel.name = AppConstants.dataKeys.level.rawValue
        levelLabel.fontColor = .appGreen
        levelLabel.fontSize = frame.height * 0.05
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.verticalAlignmentMode = .center
        levelLabel.zPosition = SceneLayer.ui.rawValue
        levelLabel.position = CGPoint(x: frame.minX + frame.width * 0.05, y: frame.maxY - frame.height * 0.1)
        levelLabel.text = AppConstants.gameText.level + "\(level)"
        addChild(levelLabel)
    }
    private func showMessage(_ message: String){
        childNode(withName: AppConstants.dataKeys.message.rawValue)?.removeFromParent()
        let messageLabel = SKLabelNode()
        messageLabel.name = AppConstants.dataKeys.message.rawValue
        messageLabel.position = CGPoint(x: frame.midX, y: slime.position.y + frame.height * 0.2)
        messageLabel.zPosition = SceneLayer.ui.rawValue
        messageLabel.numberOfLines = 2
        let paragraph              = NSMutableParagraphStyle()
        paragraph.alignment        = .center
        let attributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: UIColor.appOrange,
            .backgroundColor: UIColor.clear,
            .font: UIFont(name: AppConstants.font.regular, size: frame.height * 0.07)!,
            .paragraphStyle: paragraph
        ]
        messageLabel.attributedText = NSAttributedString(string: message, attributes: attributes)
        messageLabel.run(SKAction.fadeIn(withDuration: 0.25))
        addChild(messageLabel)
    }
    private func hideMessage(){
        if let messageLabel = childNode(withName: AppConstants.nodeNames.message) as? SKLabelNode {
            messageLabel.run(SKAction.sequence([ SKAction.fadeOut(withDuration: 0.25), SKAction.removeFromParent() ]))
        }
    }
    private func chompLabelSetup(){
        let chomp = SKLabelNode(fontNamed: AppConstants.font.regular)
        chomp.name = AppConstants.dataKeys.chomp.rawValue
        chomp.alpha = 0.0
        chomp.fontSize = frame.height * 0.05
        chomp.fontColor = .appOrange
        chomp.text = AppConstants.dataKeys.slime.rawValue
        chomp.horizontalAlignmentMode = .center
        chomp.verticalAlignmentMode = .bottom
        chomp.position = CGPoint(x: slime.position.x, y: slime.frame.maxY + 25)
        chomp.zPosition = CGFloat.random(in: -0.15...0.15)
        addChild(chomp)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.75)
        let moveUp = SKAction.moveBy(x: 0.0, y: 45, duration: 1.25)
        let groupAction = SKAction.group([fadeOut, moveUp])
        let removeFromParent = SKAction.removeFromParent()
        let chompAction = SKAction.sequence([fadeIn, groupAction, removeFromParent])
        chomp.run(chompAction)
    }
}
//MARK: - Scene logic and methods
extension GameScene {
    private func gameOver (){
        slime.stopAllSounds()
        showMessage(AppConstants.gameText.gameOverText(score: gameScore))
        slime.deathState(){ self.slime.removeFromParent() }
        gameInProgress = false
        removeAllActions()
        removeAction(forKey: AppConstants.dataKeys.drop.rawValue)
        removeAction(forKey: AppConstants.dataKeys.slime.rawValue)
        enumerateChildNodes(withName: AppConstants.nodeNames.allGameName) { node, stop in
            node.removeAction(forKey: AppConstants.dataKeys.drop.rawValue)
            node.physicsBody = nil
        }
        popRemainingDrops()
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
        enumerateChildNodes(withName: AppConstants.nodeNames.allGameName) { node, stop in
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
        let nextLevel = level + 1
        let waitAction = SKAction.wait(forDuration: 2.25)
        run(waitAction) { [weak self] in
            self?.level = nextLevel
            self?.spawnMultipleGems()
        }
    }
    private func gamePaused() { isPaused = true }
    private func gameResume() { isPaused = false }
    private func gameRestart() {
        slime.stopAllSounds()
        removeAllActions()
        removeAction(forKey: AppConstants.dataKeys.gem.rawValue)
        removeAction(forKey: AppConstants.dataKeys.drop.rawValue)
        enumerateChildNodes(withName: AppConstants.nodeNames.allGameName) { node, _ in
            node.removeFromParent()
        }
        childNode(withName: AppConstants.dataKeys.message.rawValue)?.removeFromParent()
        childNode(withName: AppConstants.dataKeys.score.rawValue)?.removeFromParent()
        childNode(withName: AppConstants.dataKeys.level.rawValue)?.removeFromParent()
        gameScore = 0
        level = 1
        dropsExpected = 0
        dropsCollected = 0
        numberOfDrop = 10
        dropSpeed = 1.0
        prevDropLocation = 0.0
        gameInProgress = false
        resetSlimePosition()
        sceneSlimeSetup()
        sceneLabelsSetup()
        playBackgroundSound()
    }
}
//MARK: - Scene touches
extension GameScene{
    private func touchDown(atPoint pos: CGPoint){
        let touchedNodes = nodes(at: pos)
        for touchedNode in touchedNodes {
            if touchedNode.name == AppConstants.dataKeys.slime.rawValue { movingSlime = true }
        }
        let distance = hypot(pos.x - slime.position.x, pos.y - slime.position.y)
        let calculatedSpeed = TimeInterval(distance / slimeSpeed) / 255
        if pos.x < slime.position.x {
            playTap()
            slime.moveToPosition(pos: pos, direction: AppConstants.dataKeys.left.rawValue, speed: calculatedSpeed)
            slime.walkState()
        }
        else {
            playTap()
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
        if gameInProgress {
            movingSlime = false
            slime.idleState()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches { self.touchDown(atPoint: touch.location(in: self)) }
        if gameInProgress == false {
            gameRestart()
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
                if gameScore > SlimeAppUserDefaults.bestScore { SlimeAppUserDefaults.bestScore = gameScore }
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
//MARK: - Scene sounds
extension GameScene {
    private func checkSoundSetting() {
        let currentSetting = SlimeAppUserDefaults.isSound
        if currentSetting != lastSoundSetting {
            playBackgroundSound()
            lastSoundSetting = currentSetting
        }
    }
    private func playBackgroundSound() {
        bgAudioNode.removeFromParent()
        forestAudioNode.removeFromParent()
        if SlimeAppUserDefaults.isSound {
            bgAudioNode = SKAudioNode(fileNamed: AppConstants.soundNames.bgSound)
            bgAudioNode.autoplayLooped = true
            bgAudioNode.isPositional = false
            bgAudioNode.run(SKAction.changeVolume(to: 0.0, duration: 0.0))
            addChild(bgAudioNode)
            forestAudioNode = SKAudioNode(fileNamed: AppConstants.soundNames.forestSound)
            forestAudioNode.autoplayLooped = true
            forestAudioNode.isPositional = false
            forestAudioNode.run(SKAction.changeVolume(to: 0.0, duration: 0.0))
            addChild(forestAudioNode)
            run(SKAction.wait(forDuration: 1.0)) { [unowned self] in
                self.audioEngine.mainMixerNode.outputVolume = 1.0
                self.bgAudioNode.run(SKAction.changeVolume(to: 0.6, duration: 2.0))
                self.forestAudioNode.run(SKAction.changeVolume(to: 0.3, duration: 2.0))
            }
        } else {
            bgAudioNode.removeFromParent()
            forestAudioNode.removeFromParent()
        }
    }
    private func playTap(){
        let removeFromParent = SKAction.removeFromParent()
        let actionGroup = SKAction.group([tapSound, removeFromParent])
        self.run(actionGroup)
    }
}
