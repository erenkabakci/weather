import Foundation
import CoreLocation

struct Forecast: Decodable {
    let timezone: String
    let currently: CurrentForecast
}

struct CurrentForecast: Decodable {
    let time: Date
    let temperature: Double?
}
