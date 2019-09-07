import Foundation
import CoreLocation

private enum QueryConstants {
    static let exclude = ("exclude", "daily,minutely,hourly,alerts,flags")
    static let units = ("units", "si")
}

private enum URLPaths {
    static let baseURL = URL(string: "https://api.darksky.net/forecast/")
    static let apiKey = "8462e4863549bfaf6201178d7a8jjd2b98"
}

protocol WeatherServiceProtocol {
    func fetchForecastDetails(location: CLLocation, completion: @escaping ((Result<CurrentForecast, NetworkError>) -> Void))
}

final class WeatherService: WeatherServiceProtocol {
    private let httpService: HttpServiceProtocol

    init(httpService: HttpServiceProtocol = HttpService()) {
        self.httpService = httpService
    }

    func fetchForecastDetails(location: CLLocation, completion: @escaping ((Result<CurrentForecast, NetworkError>) -> Void)) {
        guard let url = URLPaths.baseURL else { return }

        var urlRequest = URLRequest(url: url
            .appendingPathComponent((URLPaths.apiKey), isDirectory: false)
            .appendingPathComponent(location.queryString(), isDirectory: false)
            .appendingParameters(urlParameters: [QueryConstants.exclude, QueryConstants.units])
        )
        urlRequest.httpMethod = "GET"
        httpService.get(urlRequest: urlRequest, completion: { (result: (Result<Forecast, NetworkError>)) in
            completion(result.map { $0.currently })
        })
    }
}

private extension CLLocation {
    func queryString() -> String {
        return "\(coordinate.latitude),\(coordinate.longitude)"
    }
}
