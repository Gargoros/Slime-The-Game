
import SwiftUI
import SpriteKit

extension SKSpriteNode {
    func loadTextures(atlas: String, prefix: String, startAt: Int, stopAt: Int) -> [SKTexture] {
        var textureArray = [SKTexture]()
        let textureAtlas = SKTextureAtlas(named: atlas)
        for i in startAt...stopAt {
            let textureName = "\(prefix)_0\(i + 1)"
            let temp = textureAtlas.textureNamed(textureName)
            textureArray.append(temp)
        }
        return textureArray
    }
    func startAnimation(textures: [SKTexture], speed: Double, name: String, count: Int, resize: Bool, restore: Bool){
        if (action(forKey: name) == nil){
            let animation = SKAction.animate(with: textures, timePerFrame: speed, resize: resize, restore: restore)
            if count == 0 {
                let repeatAction = SKAction.repeatForever(animation)
                run(repeatAction, withKey: name)
            } else if count == 1 {
                run(animation, withKey: name)
            } else {
                let repeatAction = SKAction.repeat(animation, count: count)
                run(repeatAction, withKey: name)
            }
        }
        
    }
    func endlessScroll(speed: TimeInterval) {
        let moveAction = SKAction.moveBy(x: -self.size.width, y: 0, duration: speed)
        let resetAction = SKAction.moveBy(x: self.size.width, y: 0, duration: speed)
        let sequenceAction = SKAction.sequence([moveAction, resetAction])
        let repeatAction = SKAction.repeatForever(sequenceAction)
        self.run(repeatAction)
    }
}

extension SKNode {
    func setupScrollingView(imageName name: String, layer: SceneLayer, blocks: Int, speed: TimeInterval){
        for i in 0..<blocks {
            let spriteNode = SKSpriteNode(imageNamed: name)
            spriteNode.anchorPoint = CGPoint.zero
            spriteNode.position = CGPoint(x: CGFloat(i)  * spriteNode.size.width, y: 0)
            spriteNode.zPosition = layer.rawValue
            spriteNode.name = name
            spriteNode.endlessScroll(speed: speed)
            addChild(spriteNode)
        }
    }
}

extension SKScene {
    func sceneGameSound(_ gameSound: SKAction, completion: (() -> Void)? = nil) {
        if SlimeAppUserDefaults.isSound {
            let soundAction = gameSound
            if let completion = completion {
                let completionAction = SKAction.run(completion)
                let sequence = SKAction.sequence([soundAction, completionAction])
                run(sequence) }
            else { run(soundAction) }
        }
        else { completion?() }
    }
}

extension View {
    func mainModifier() -> some View {
        self.modifier(AppMainViewModifier())
    }
}
