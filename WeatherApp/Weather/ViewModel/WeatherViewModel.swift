import Foundation
import CoreLocation

struct WeatherForecast {
    let date: String
    let temperature: String
    let min, max: String
}

import Foundation

protocol WeatherViewModelDelegate: AnyObject {
    func didUpdateWeatherData()
    func didFailWithError(_ error: Error)
}

class WeatherViewModel {
    weak var delegate: WeatherViewModelDelegate?
    
    var currentTemperature: String = ""
    var sevenDayForecast: [WeatherForecast] = []
    
    func fetchWeatherData(for coordinate: CLLocationCoordinate2D) {
        WeatherService.shared.fetchWeatherData(for: coordinate) { [weak self] result in
            switch result {
            case .success(let weatherData):
                self?.processWeatherData(weatherData)
            case .failure(let error):
                self?.delegate?.didFailWithError(error)
            }
        }
    }
    
    private func processWeatherData(_ weatherData: WeatherData) {
        // Process current weather data
        currentTemperature = "\(Int(weatherData.current.temp ?? 0))°C"
        
        // Process daily weather forecast
        sevenDayForecast = weatherData.daily.map { dailyWeather in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let date = dateFormatter.string(from: dailyWeather.dt)
            let temperature = "\(Int(dailyWeather.temp.day))°C"
            let minTemp = "\(Int(dailyWeather.temp.min))°C"
            let maxTemp = "\(Int(dailyWeather.temp.max))°C"
            return WeatherForecast(date: date, temperature: temperature, min: minTemp, max: maxTemp)
        }
        
        delegate?.didUpdateWeatherData()
    }
}
