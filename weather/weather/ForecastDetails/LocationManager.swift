import Foundation
import CoreLocation

enum LocationError: Error {
    case service
    case permission
    case geocoding(_: Error)
    case unknown
}

protocol LocationManagable {
    var latestLocation: ((Result<CLLocation, LocationError>) -> Void) { get }
    func startLocating()
}

final class LocationManager: NSObject, LocationManagable {
    private let manager = CLLocationManager()
    var latestLocation: ((Result<CLLocation, LocationError>) -> Void) = { _ in }

    override init() {
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        checkPermission()
    }

    private func checkPermission() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                latestLocation(.failure(.permission))
            case .authorizedAlways, .authorizedWhenInUse:
                manager.startUpdatingLocation()
            @unknown default:
                latestLocation(.failure(.service))
            }
        } else {
            latestLocation(.failure(.service))
        }
    }

    func startLocating() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return latestLocation(.failure(.unknown)) }
        latestLocation(.success(location))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        latestLocation(.failure(.geocoding(error)))
    }
}
