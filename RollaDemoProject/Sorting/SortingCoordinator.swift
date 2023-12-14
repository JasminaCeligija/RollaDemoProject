import UIKit

struct SortingCoordinator: Coordinator {
    func start() -> UIViewController {
        let viewModel = SortingViewModel()
        let viewController = SortingView(viewModel: viewModel).hosted
        viewController.withTabBarItem(title: "Sort", image: UIImage(systemName: "arrow.up.and.down"))
        return viewController
    }
}
