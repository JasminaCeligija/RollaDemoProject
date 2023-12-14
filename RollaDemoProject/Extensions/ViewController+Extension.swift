import UIKit

extension UIViewController {
    func withTabBarItem(title: String, image: UIImage?, selectedImage: UIImage? = nil) {
        self.tabBarItem = UITabBarItem(
            title: title,
            image: image,
            selectedImage: selectedImage
        )
    }
}
