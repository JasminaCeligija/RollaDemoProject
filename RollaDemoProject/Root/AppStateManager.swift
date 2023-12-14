import UIKit

private enum AppState {
    case main(
        BLECoordinator,
        LocationCoordinator,
        SortingCoordinator,
        MainRootNavigator
    )

    var rootNavigator: any Navigating {
        switch self {
        case .main(_, _, _, let mainRootNavigator):
            return mainRootNavigator
        }
    }
}

@MainActor
final class AppStateManager {
    private let rootNavigation: RootNavigating
    private var state: AppState {
        didSet {
            start()
        }
    }

    init(rootNavigation: RootNavigating) {
        self.rootNavigation = rootNavigation
        let bleCoordinator = BLECoordinator()
        let locationCoordinator = LocationCoordinator()
        let sortingCoordinator = SortingCoordinator()
        let mainRootNavigator = MainRootNavigator()

        mainRootNavigator.viewControllers = [
            bleCoordinator.start(),
            locationCoordinator.start(),
            sortingCoordinator.start()
        ]

        self.state = .main(
            bleCoordinator,
            locationCoordinator,
            sortingCoordinator,
            mainRootNavigator
        )
    }

    func start() {
        rootNavigation.replaceRoot(with: state.rootNavigator.viewController)
    }
}
