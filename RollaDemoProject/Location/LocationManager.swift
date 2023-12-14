import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private var locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    @Published var traveledDistance: CLLocationDistance = 0.0
    @Published var currentSpeed: CLLocationSpeed = 0.0
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined

    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
//        locationManager.allowsBackgroundLocationUpdates = true
//        locationManager.showsBackgroundLocationIndicator = true
        locationManager.distanceFilter = 1
        locationManager.delegate = self
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        lastLocation = nil
        traveledDistance = 0.0
        locationManager.startUpdatingLocation()
    }

    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = AuthorizationStatus(from: manager.authorizationStatus)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            return
        }

        currentSpeed = abs(newLocation.speed)

        guard newLocation.horizontalAccuracy >= 0, newLocation.horizontalAccuracy <= 20 else {
            print("Remove noise.")
            return
        }

        if let lastLocation = lastLocation {
            // Check if the distance change is greater than or equal to half of the horizontal accuracy
            let distance = newLocation.distance(from: lastLocation)
            let distanceThreshold = newLocation.horizontalAccuracy * 0.5

            if distance >= distanceThreshold {
                self.traveledDistance += distance
                self.lastLocation = newLocation
            } else {
                print("Discarding location update due to small distance change.")
            }
        } else {
            self.lastLocation = newLocation
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:\(error)")
    }
}

enum AuthorizationStatus {
    case denied
    case notDetermined
    case authorizedWhenInUse
    case authorizedAlways
    case restricted
    case other

    init(from status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            self = .denied
        case .notDetermined:
            self = .notDetermined
        case .authorizedWhenInUse:
            self = .authorizedWhenInUse
        case .authorizedAlways:
            self = .authorizedAlways
        case .restricted:
            self = .restricted
        default:
            self = .other
        }
    }

    var title: String {
        switch self {
        case .denied:
            return "Location Access Denied"
        case .notDetermined:
            return "Location Access Not Determined"
        case .authorizedWhenInUse, .authorizedAlways:
            return "Location Access Granted"
        case .restricted:
            return "Location Access Restricted"
        case .other:
            return "Location Access Unknown"
        }
    }

    var message: String {
        switch self {
        case .denied:
            return "Location access is denied. Please enable it in Settings."
        case .notDetermined:
            return "Location access is not determined. Please allow access in Settings."
        case .authorizedWhenInUse, .authorizedAlways:
            return "Location access is granted. You can use the app with location services."
        case .restricted:
            return "Location access is restricted by parental control."
        case .other:
            return "Location access status is not handled."
        }
    }
}
