import Foundation
import CoreLocation

protocol LocationManagable: AnyObject {
    var latestLocation: CLLocation? { get }
    var permissionDidGrant: (() -> Void)? { get set }
    func startLocating()
}

final class LocationManager: NSObject, LocationManagable {
    private let manager = CLLocationManager()

    var latestLocation: CLLocation? {
        didSet {
            if oldValue == nil && latestLocation != nil {
                permissionDidGrant?()
            }
        }
    }
    var permissionDidGrant: (() -> Void)?

    override init() {
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    func startLocating() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        latestLocation = location
    }
}
