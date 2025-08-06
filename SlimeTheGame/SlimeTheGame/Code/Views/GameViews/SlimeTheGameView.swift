
import SwiftUI
import SpriteKit

struct SlimeTheGameView: View {
    //MARK: - Properties
    @Binding private var isPresented: Bool
    @StateObject private var gameScene = GameScene()
    //MARK: - Init
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self._gameScene = StateObject(wrappedValue: GameScene())
    }
    //MARK: - View
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                SpriteView(scene: gameScene)
            }
            .onAppear { setupGameScene(geometry.size) }
            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
        }
        .mainModifier()
    }
    private func setupGameScene(_ size: CGSize){
        gameScene.gameView = self
        gameScene.size = size
        gameScene.scaleMode = .resizeFill
        gameScene.physicsWorld.contactDelegate = gameScene
    }
}
