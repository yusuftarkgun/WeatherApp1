import UIKit
import CoreLocation

class ViewController: UIViewController, WeatherViewModelDelegate, UITableViewDataSource{
    
    @IBOutlet weak var currentLocationView: UILabel!
    @IBOutlet weak var sevenDayTableView: UITableView!
    @IBOutlet weak var currentIcon: UIImageView!
    @IBOutlet weak var currentTemperatureLabel: UILabel!

    
    
    
    // MARK: - Properties
    let sevenDaysTableCell = UITableView()
    private let viewModel = WeatherViewModel()
    private let locationManager = LocationManager.shared
     var latitude  = 0.0
     var longitude  = 0.0
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
      //  updateUI(with: CLLocation(latitude: latitude, longitude: longitude))
        let backgroundImage = UIImage(named: "pexels-pixabay-209831.jpg")
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFill
        self.view.backgroundColor = UIColor(patternImage: backgroundImage!)
     //   sevenDayTableView.backgroundView = imageView
        sevenDayTableView.backgroundColor = UIColor.clear
        

    }
    
    // MARK: - Setup UI
    private func setupUI() {
        viewModel.delegate = self
        sevenDayTableView.dataSource = self
        sevenDayTableView.rowHeight = 50
        let nib = UINib(nibName: "SevenDaysTableCell", bundle: nil)
        sevenDayTableView.register(nib, forCellReuseIdentifier: SevenDaysTableCell.identifier)
        // Fetch weather data after setting up UI
        fetchWeatherData()
    }
    
    // MARK: - Update UI with Location
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
    
    // MARK: - Fetch Weather Data
    private func fetchWeatherData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
            if let currentLocation = LocationManager.shared.currentLocation {
                viewModel.fetchWeatherData(for: currentLocation.coordinate)
                updateUI(with: currentLocation)
            }
        }
    }
    
    // MARK: - WeatherViewModelDelegate
    func didUpdateWeatherData() {
        currentTemperatureLabel.text = viewModel.currentTemperature

        DispatchQueue.main.async {
            let iconCode = self.viewModel.currentIconCode

            let iconURL = URL(string: "https://openweathermap.org/img/wn/\(iconCode).png")
            self.currentIcon.kf.setImage(with: iconURL)
            self.sevenDayTableView.reloadData()
            
        }
    }
    
    func didFailWithError(_ error: Error) {
        DispatchQueue.main.async {
            // Handle error
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sevenDayForecast.count
    }
    
    // ViewController.swift
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SevenDaysTableCell.identifier, for: indexPath) as! SevenDaysTableCell
        let forecast = viewModel.sevenDayForecast[indexPath.row]
        cell.weatherData = forecast
        return cell
    }

    
}

