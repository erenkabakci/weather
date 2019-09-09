import XCTest
import CoreLocation
@testable import weather

final class ForecastPresenterDetailTests: XCTestCase {
    private var presenter: ForecastPresenter!
    private var view: MockView!
    private var locationManager: MockLocationManager!
    private var service: MockWeatherService!
    private let dateFormatter = DateFormatter()

    override func setUp() {
        super.setUp()

        view = MockView()
        locationManager = MockLocationManager()
        service = MockWeatherService()
        presenter = ForecastPresenter(view: view, service: service, locationManager: locationManager)
    }

    func test_givenLocationError_whenViewTriggersForecast_thenlocationManagerShouldStartLocating_thenServiceShouldFetch_andViewShouldError() {
        let expectation = self.expectation(description: "view display result async expectation is not fulfilled")
        view.asyncExpectation = expectation
        locationManager.latestLocation = nil
        view.forecastTrigger?()

        let expectedResult = ForecastDetailViewModel(summary: "Location service or internet connection issue. \nPlease check your settings & \"Retry\"",
                                                     date: nil,
                                                     temperature: nil,
                                                     buttonDescription: "Retry")

        waitForExpectations(timeout: 0.5, handler: nil)

        XCTAssertEqual(self.service.callCount, 0)
        XCTAssertEqual(view.callCount, 1)
        XCTAssertEqual(view.viewResult!.0, expectedResult)
    }

    func test_givenServiceError_whenViewTriggersForecast_thenlocationManagerShouldStartLocating_andViewShouldNotReact() {
        locationManager.latestLocation = CLLocation(latitude: 10.0, longitude: 10.0)
        service.error = true
        view.forecastTrigger?()

        XCTAssertEqual(self.service.callCount, 1)
        XCTAssertEqual(view.callCount, 0)
    }

    func test_whenViewTriggersForecast_thenlocationManagerShouldStartLocating_thenServiceShouldFetch_andViewShouldPresent() {
        let expectation = self.expectation(description: "view display result async expectation is not fulfilled")
        view.asyncExpectation = expectation
        locationManager.latestLocation = CLLocation(latitude: 10.0, longitude: 10.0)
        view.forecastTrigger?()

        dateFormatter.dateFormat = "EEEE, d-MMM"
        dateFormatter.locale = Locale.current

        let expectedResult = ForecastDetailViewModel(summary: "timezone",
                                                     date: dateFormatter.string(from: Date()),
                                                     temperature: "10 °C",
            buttonDescription: "Refresh")

        waitForExpectations(timeout: 0.5, handler: nil)

        XCTAssertEqual(self.service.callCount, 1)
        XCTAssertEqual(view.callCount, 1)
        XCTAssertEqual(view.viewResult!.0, expectedResult)
    }

    func test_givenPermissionGrant_shouldFetchForecastDetails() {
        locationManager.latestLocation = CLLocation(latitude: 10.0, longitude: 10.0)
        service.error = true
        view.forecastTrigger?()

        XCTAssertEqual(self.service.callCount, 1)
        XCTAssertEqual(view.callCount, 0)

        self.locationManager.permissionDidGrant?()
        XCTAssertEqual(self.service.callCount, 2)
        XCTAssertEqual(view.callCount, 0)
    }

    final class MockView: Verifiable, ForecastViewable {
        var asyncExpectation: XCTestExpectation?
        private (set) var viewResult: (ForecastDetailViewModel, Bool)?

        var forecastTrigger: (() -> Void)?
        func displayResult(result: ForecastDetailViewModel, error: Bool) {
            viewResult = (result, error)
            callCount += 1
            asyncExpectation?.fulfill()
        }
    }

    final class MockLocationManager: Verifiable, LocationManagable {
        var latestLocation: CLLocation?
        var permissionDidGrant: (() -> Void)?

        func startLocating() {
            callCount += 1
        }
    }

    final class MockWeatherService: Verifiable, WeatherServiceProtocol {
        var error = false
        func fetchForecastDetails(location: CLLocation, completion: @escaping ((Result<Forecast, NetworkError>) -> Void)) {
            callCount += 1
            if error {
                completion(.failure(.unknown))
            } else {
                completion(.success(Forecast(timezone: "timezone", currently: CurrentForecast(time: Date(), temperature: 10))))
            }
        }
    }
}
