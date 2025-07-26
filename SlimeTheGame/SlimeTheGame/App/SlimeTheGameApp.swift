
import SwiftUI

@main
struct SlimeTheGameApp: App {
    //MARK: - Properties
    @State var isMenu = false
    @State var isLoad = true
    //MARK: - Views
    var body: some Scene {
        WindowGroup {
            SlimeTheGameView(isPresented: .constant(true))
                .mainModifier()
        }
    }
}
