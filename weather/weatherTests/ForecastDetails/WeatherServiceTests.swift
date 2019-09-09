import XCTest
import CoreLocation
@testable import weather

final class WeatherServiceTests: XCTestCase {
    private var service: WeatherServiceProtocol!
    private var httpService: MockHttpService!

    override func setUp() {
        super.setUp()
        httpService = MockHttpService()
        service = WeatherService(httpService: httpService)
    }

    func test_fetchingResult_shouldSuccesfullyReturnModel() {
        service.fetchForecastDetails(location: CLLocation(latitude: 10, longitude: 10)) { (result: (Result<Forecast, NetworkError>)) in
            if case let .success(model) = result {
                XCTAssertEqual(model.timezone, "timezone")
                XCTAssertEqual(self.httpService.callCount, 1)
                XCTAssertEqual(self.httpService.urlRequest?.httpMethod, "GET")
                XCTAssertEqual(self.httpService.urlRequest?.url?.absoluteString,
                               "https://api.darksky.net/forecast/8462e4863549bfaf6201178d7a8d2b98/10.0,10.0?exclude=daily,minutely,hourly,alerts,flags&units=si")
            } else {
                XCTFail()
            }
        }
    }

    func test_fetchingResult_withError_shouldFail() {
        httpService.error = true
        service.fetchForecastDetails(location: CLLocation(latitude: 10, longitude: 10)) { (result: (Result<Forecast, NetworkError>)) in
            if case let .failure(error) = result {
                XCTAssertEqual(error, .unknown)
                XCTAssertEqual(self.httpService.callCount, 1)
                XCTAssertEqual(self.httpService.urlRequest?.httpMethod, "GET")
                XCTAssertEqual(self.httpService.urlRequest?.url?.absoluteString,
                               "https://api.darksky.net/forecast/8462e4863549bfaf6201178d7a8d2b98/10.0,10.0?exclude=daily,minutely,hourly,alerts,flags&units=si")
            } else {
                XCTFail()
            }
        }
    }

    class MockHttpService: Verifiable, HttpServiceProtocol {
        var error = false
        private (set) var urlRequest: URLRequest?
        func get<T>(urlRequest: URLRequest, completion: @escaping ((Result<T, NetworkError>) -> Void)) where T : Decodable {
            self.urlRequest = urlRequest
            callCount += 1
            if error {
                completion(.failure(.unknown))
            } else {
                completion(.success(Forecast(timezone: "timezone", currently: CurrentForecast(time: Date(), temperature: 10)) as! T))
            }
        }
    }
}
