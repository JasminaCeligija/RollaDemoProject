import UIKit

struct LocationCoordinator: Coordinator {
    func start() -> UIViewController {
        let locationManager = LocationManager()
        let viewModel = LocationViewModel(locationManager: locationManager)
        let viewController = LocationView(viewModel: viewModel).hosted
        viewController.withTabBarItem(title: "Location", image: UIImage(systemName: "location"))
        return viewController
    }
}
