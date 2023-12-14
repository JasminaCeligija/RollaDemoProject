import UIKit

protocol RootNavigating {
    func replaceRoot(with viewController: UIViewController)
}

extension UIWindow: RootNavigating {
    func replaceRoot(with viewController: UIViewController) {
        rootViewController = viewController
        makeKeyAndVisible()
    }
}
