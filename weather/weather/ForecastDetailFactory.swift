import Foundation

class ForecastDetailFactory {
    private var presenter: ForecastPresenter?

    func createView() -> ForecastViewController {
        let viewController = ForecastViewController()
        presenter = ForecastPresenter(view: viewController)
        return viewController
    }
}
