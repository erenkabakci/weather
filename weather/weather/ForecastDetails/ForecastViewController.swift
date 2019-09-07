import UIKit
import CoreLocation

class ForecastViewController: UIViewController {
    private let locationManager = LocationManager()
    private let service = WeatherService()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.red

        locationManager.startLocating()

        locationManager.latestLocation = { result in
            print(result)
        }

        service.fetchForecastDetails(location: CLLocation(latitude: 10.5, longitude: 10.6)) { (result) in
            
        }
    }
}

