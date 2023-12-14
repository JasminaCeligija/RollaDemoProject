import UIKit

final class MainRootNavigator: UITabBarController {

}

extension MainRootNavigator: Navigating {
    var viewController: UIViewController { self }
}

protocol Navigating {
    var viewController: UIViewController { get }
}
