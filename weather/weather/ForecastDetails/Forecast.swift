import Foundation
import CoreLocation

struct Forecast: Decodable {
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let timezone: String
    let currently: CurrentForecast
}

struct CurrentForecast: Decodable {
    let time: Date
    let temperature: Double?
    let summary: String?
    let precipProbability: Double?
    let precipType: String?
}
