import UIKit
import CoreLocation

class ViewController: UIViewController, WeatherViewModelDelegate {
    
    @IBOutlet weak var currentLocationView: UILabel!
    @IBOutlet weak var sevenDayTableView: UITableView!
    @IBOutlet weak var currentIcon: UIImageView!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    
    private let viewModel = WeatherViewModel()
    private let locationManager = LocationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(handleMapLocationSelection(_:)), name: Notification.Name("DidSelectMapLocation"), object: nil)
        
        // Arka plan resmini ayarla
        let backgroundImage = UIImage(named: "pexels-pixabay-209831.jpg")
        self.view.backgroundColor = UIColor(patternImage: backgroundImage!)
        
        sevenDayTableView.backgroundColor = UIColor.clear
    }
    
    func setupUI() {
        viewModel.delegate = self
        sevenDayTableView.dataSource = self
        sevenDayTableView.rowHeight = 50
        let nib = UINib(nibName: "SevenDaysTableCell", bundle: nil)
        sevenDayTableView.register(nib, forCellReuseIdentifier: SevenDaysTableCell.identifier)
        fetchWeatherData()
    }
    
    @objc func handleMapLocationSelection(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let weatherData = userInfo["weatherData"] as? WeatherData {
                displayWeatherData(weatherData)
            }
            if let coordinate = userInfo["coordinate"] as? CLLocationCoordinate2D {
                // İsteğe bağlı, seçilen koordinatları kullanarak farklı bir işlem yapabilirsiniz.
            }
        }
    }
    
    private func fetchWeatherData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            if let currentLocation = self.locationManager.currentLocation {
                self.viewModel.fetchWeatherData(for: currentLocation.coordinate)
                self.updateUI(with: currentLocation)
            }
        }
    }
    
    private func updateUI(with location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            guard error == nil else {
                print("Reverse geocoding failed with error: \(error!.localizedDescription)")
                return
            }
            guard let placemark = placemarks?.first else {
                print("No placemark found")
                return
            }
            if let city = placemark.locality {
                DispatchQueue.main.async {
                    self.currentLocationView.text = "\(city)"
                }
            }
        }
    }
    
    func displayWeatherData(_ weatherData: WeatherData) {
        DispatchQueue.main.async {
            self.currentTemperatureLabel.text = "\(weatherData.current.temp)°C"
            
            if let currentWeather = weatherData.current.weather.first {
                let iconCode = currentWeather.icon ?? "DefaultIconCode"
                let iconURL = URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")
                self.currentIcon.kf.setImage(with: iconURL)
            }
            
            self.sevenDayTableView.reloadData()
        }
    }
    
    func didUpdateWeatherData() {
        // Bu metod WeatherViewModel tarafından çağrıldığında, UI'yı güncelle
        if let currentLocation = locationManager.currentLocation {
            updateUI(with: currentLocation)
        }
    }
    
    func didFailWithError(_ error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sevenDayForecast.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SevenDaysTableCell.identifier, for: indexPath) as! SevenDaysTableCell
        let forecast = viewModel.sevenDayForecast[indexPath.row]
        cell.weatherData = forecast
        return cell
    }
}
