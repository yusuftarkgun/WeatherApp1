import UIKit
import CoreLocation

final class ViewController: UIViewController {
    
    @IBOutlet private weak var currentLocationView: UILabel!
    @IBOutlet private weak var sevenDayTableView: UITableView!
    @IBOutlet private weak var currentIcon: UIImageView!
    @IBOutlet private weak var LaunchScreen: UIImageView!
    @IBOutlet private weak var currentTemperatureLabel: UILabel!
    let sevenDaysTableCell = UITableView()
    let viewModel = WeatherViewModel()
    private let locationManager = LocationManager.shared
    
    private var latitude  = 0.0
    private var longitude  = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchWeatherData()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(handleLocationUpdate(_:)), name: NSNotification.Name("UpdateLocation"), object: nil)
    
    }
    
    @objc private func handleLocationUpdate(_ notification: Notification) {
        if let location = notification.object as? CLLocationCoordinate2D {
            viewModel.fetchWeatherData(for: location)
            updateUI(with: CLLocation(latitude: location.latitude, longitude: location.longitude))
        }
    }
    
    private func setupUI() {
        viewModel.delegate = self
        
        sevenDayTableView.dataSource = self
        sevenDayTableView.rowHeight = 50
        let nib = UINib(nibName: "SevenDaysTableCell", bundle: nil)
        sevenDayTableView.register(nib, forCellReuseIdentifier: SevenDaysTableCell.identifier)
        sevenDayTableView.backgroundColor = UIColor.clear
        
        let backgroundImage = UIImage(named: "pexels-pixabay-209831.jpg")
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFill
        view.backgroundColor = UIColor(patternImage: backgroundImage!)
    }
    
    private func updateUI(with location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard error == nil else {
                print("Reverse geocoding failed with error: \(error!.localizedDescription)")
                return
            }
            guard let placemark = placemarks?.first else {
                print("No placemark found")
                return
            }
            if let city = placemark.locality {
                self.currentLocationView.text = "\(city)"
            }
        }
    }
    
    private func fetchWeatherData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){ [self] in
            if let currentLocation = locationManager.currentLocation {
                viewModel.fetchWeatherData(for: currentLocation.coordinate)
                updateUI(with: currentLocation)
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sevenDayForecast?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SevenDaysTableCell.identifier, for: indexPath) as! SevenDaysTableCell
        let forecast = viewModel.sevenDayForecast?[indexPath.row]
        cell.weatherData = forecast
        return cell
    }
}

extension ViewController: WeatherViewModelDelegate {

    func didUpdateWeatherData() {
        DispatchQueue.main.async {
            self.currentTemperatureLabel.text = self.viewModel.currentTemperature
            let iconCode = self.viewModel.currentIconCode
            let iconURL = URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")
            self.currentIcon.kf.setImage(with: iconURL)
            self.sevenDayTableView.reloadData()
        }
    }
    
    func didFailWithError(_ error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Ops!", message: "\(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
