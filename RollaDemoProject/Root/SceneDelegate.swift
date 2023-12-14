import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var appStateManager: AppStateManager!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)

        appStateManager = AppStateManager(
            rootNavigation: window
        )

        appStateManager.start()
    }
}

