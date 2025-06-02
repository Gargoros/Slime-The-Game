
import UIKit
import SpriteKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

            window = UIWindow(frame: UIScreen.main.bounds)
            let skView = SKView(frame: window!.bounds)
            let scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .aspectFill
            skView.presentScene(scene)

            let viewController = UIViewController()
            viewController.view = skView

            window?.rootViewController = viewController
            window?.makeKeyAndVisible()

            return true
        }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}


}

