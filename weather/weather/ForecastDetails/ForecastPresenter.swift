import Foundation

enum DisplayStateFailure: Error {
    case location
}

final class ForecastPresenter {
    private let view: ForecastViewable
    private let service: WeatherServiceProtocol
    private let locationManager: LocationManagable
    private let dateFormatter = DateFormatter()

    init(view: ForecastViewable,
         service: WeatherServiceProtocol = WeatherService(),
         locationManager: LocationManagable = LocationManager()) {
        self.view = view
        self.service = service
        self.locationManager = locationManager

        dateFormatter.dateFormat = "EEEE, d-MMM"
        dateFormatter.locale = Locale.current

        self.view.forecastTrigger = { [unowned self] in
            self.locationManager.startLocating()
            self.fetchForecastDetails()
        }

        self.locationManager.permissionDidGrant = { [unowned self] in
            self.fetchForecastDetails()
        }
    }
    
    private func fetchForecastDetails() {
        guard let location = self.locationManager.latestLocation else {
            self.handleResult(result: .failure(DisplayStateFailure.location))
            return
        }

        self.service.fetchForecastDetails(location: location, completion: { apiResult in
            if case let .success(forecast) = apiResult {
                self.handleResult(result: .success(forecast))
            }
        })
    }

    private func handleResult(result : Result<Forecast, Error>) {
        DispatchQueue.main.async { [weak self] in
            if case let .success(forecast) = result {
                self?.view.displayResult(result:
                    ForecastDetailViewModel(summary: forecast.timezone,
                                            date: self?.dateFormatter.string(from: forecast.currently.time),
                                            temperature: "\(Int(forecast.currently.temperature ?? 0)) °C",
                        buttonDescription: "Refresh"),
                                   error: false)
            } else {
                self?.view.displayResult(result:
                    ForecastDetailViewModel(summary: "Location service or internet connection issue. \nPlease check your settings & \"Retry\"",
                                            date: nil,
                                            temperature: nil,
                                            buttonDescription: "Retry"),
                                   error: true)
            }
        }
    }
}
