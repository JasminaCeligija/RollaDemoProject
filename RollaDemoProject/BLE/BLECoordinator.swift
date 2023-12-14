import UIKit

struct BLECoordinator: Coordinator {
    func start() -> UIViewController {
        let viewModel = BLEViewModel(bluetoothManager: BluetoothManager())
        let viewController = BLEView(viewModel: viewModel).hosted
        viewController.withTabBarItem(title: "Scan", image: UIImage(systemName: "scope"))
        return viewController
    }
}
