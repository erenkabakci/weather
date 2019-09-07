import UIKit
import CoreLocation

protocol ForecastViewable: AnyObject {
    var forecastTrigger: (() -> Void)? { get set }
    func displayResult(result: ForecastDetailViewModel, error: Bool)
}

class ForecastViewController: UIViewController, ForecastViewable {
    var forecastTrigger: (() -> Void)?

    private let timezoneLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let dateLabel = UILabel()
    private let triggerButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        forecastTrigger?()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        forecastTrigger?()
    }

    private func setupViews() {
        view.backgroundColor = UIColor.white

        let verticalContainer = UIStackView(arrangedSubviews: [timezoneLabel, dateLabel, temperatureLabel, triggerButton])
        verticalContainer.alignment = .leading
        verticalContainer.spacing = 10.0
        verticalContainer.distribution = .fillProportionally
        verticalContainer.axis = .vertical
        verticalContainer.setCustomSpacing(0, after: timezoneLabel)

        verticalContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(verticalContainer)

        NSLayoutConstraint.activate([verticalContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
                                     verticalContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0),
                                     verticalContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
                                     triggerButton.heightAnchor.constraint(equalToConstant: 44.0)])

        timezoneLabel.numberOfLines = 0
        timezoneLabel.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
        temperatureLabel.font = UIFont.systemFont(ofSize: 60, weight: .bold)

        triggerButton.addTarget(self, action: #selector(triggerButtonTapped), for: .touchUpInside)
        triggerButton.layer.cornerRadius = 5.0
        triggerButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        triggerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        triggerButton.setTitleColor(UIColor.gray, for: .highlighted)
        triggerButton.backgroundColor = UIColor.blue
    }

    @objc func triggerButtonTapped() {
        forecastTrigger?()
    }

    func displayResult(result: ForecastDetailViewModel, error: Bool) {
        dateLabel.isHidden = error
        temperatureLabel.isHidden = error

        timezoneLabel.text = result.timeZone
        dateLabel.text = result.date
        temperatureLabel.text = result.temperature
        triggerButton.setTitle(result.buttonDescription, for: .normal)
    }
}
