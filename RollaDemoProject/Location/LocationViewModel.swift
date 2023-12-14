import UIKit
import CoreLocation
import Combine

protocol LocationViewModelType: ObservableObject {
    var formattedCurrentSpeed: String { get }
    var formattedTraveledDistance: String { get }
    var primaryButtonText: String { get }
    var authorizationAlert: AuthorizationAlert? { get set }
    func didTapPrimaryButton()
    func didTapOpenSettingsButton()
}

final class LocationViewModel: LocationViewModelType {
    private let locationManager: LocationManager
    private var cancellables: Set<AnyCancellable> = []
    private var authorizationStatus: AuthorizationStatus = .notDetermined
    private var isTracking = false

    @Published var primaryButtonText = "Start"
    @Published var formattedCurrentSpeed = ""
    @Published var formattedTraveledDistance = ""
    @Published  var authorizationAlert: AuthorizationAlert?

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        setupBindings()
    }

    private func setupBindings() {
        locationManager.$traveledDistance
            .receive(on: DispatchQueue.main)
            .map { traveledDistance in
                return String(format: "Traveled Distance: %.2f m", traveledDistance)
            }
            .assign(to: \.formattedTraveledDistance, on: self)
            .store(in: &cancellables)

        locationManager.$currentSpeed
            .receive(on: DispatchQueue.main)
            .map { currentSpeed in
                return String(format: "Speed: %.2f m/s", currentSpeed)
            }
            .assign(to: \.formattedCurrentSpeed, on: self)
            .store(in: &cancellables)

        locationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newAuthorizationStatus in
                guard let self = self else { return }
                if isTracking, newAuthorizationStatus != .authorizedAlways || newAuthorizationStatus != .authorizedWhenInUse {
                    stopTracking()
                }
                self.authorizationStatus = newAuthorizationStatus
            }
            .store(in: &cancellables)
    }

    func didTapPrimaryButton() {
        switch authorizationStatus {
        case .denied, .restricted, .other:
            authorizationAlert = AuthorizationAlert(
                title: authorizationStatus.title,
                message: authorizationStatus.message
            )
        case .notDetermined:
            locationManager.requestLocation()
        case .authorizedWhenInUse, .authorizedAlways:
            handlePrimaryButtonTapped()
        }
    }

    private func handlePrimaryButtonTapped() {
        isTracking.toggle()
        guard isTracking else {
            stopTracking()
            return
        }
        startTracking()
    }

    private func startTracking() {
        primaryButtonText = "Stop"
        locationManager.startTracking()
    }

    private func stopTracking() {
        primaryButtonText = "Start"
        locationManager.stopTracking()
    }

    func didTapOpenSettingsButton() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
    }
}

struct AuthorizationAlert: Identifiable {
    var id = UUID()
    let title: String
    let message: String
    let buttonTitle: String = "Settings"
}
