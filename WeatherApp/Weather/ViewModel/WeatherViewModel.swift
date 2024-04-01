import Foundation
import CoreLocation
import Foundation

struct WeatherForecast {
    let date: String
    let temperature: String
    let min, max: String
    let iconCode: String?
}

protocol WeatherViewModelDelegate: AnyObject {
    func didUpdateWeatherData()
    func didFailWithError(_ error: Error)
}

class WeatherViewModel {
    weak var delegate: WeatherViewModelDelegate?
    
    var currentTemperature: String = ""
    var currentIconCode: String = ""
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
        currentTemperature = "\(Int(weatherData.current.temp))°C"
        if let currentWeather = weatherData.current.weather.first{
            currentIconCode = currentWeather.icon
        }
        
        // Process daily weather forecast
        sevenDayForecast = weatherData.daily.map { dailyWeather in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let date = dateFormatter.string(from: dailyWeather.dt)
            let temperature = "\(Int(dailyWeather.temp.day))°C"
            let minTemp = "\(Int(dailyWeather.temp.min))°C"
            let maxTemp = "\(Int(dailyWeather.temp.max))°C"
            let iconCode = dailyWeather.weather.first?.icon
            let iconURL = dailyWeather.iconCode
            _ = "https://openweathermap.org/img/wn/\(iconCode ?? "").png"
                
            return WeatherForecast(date: date, temperature: temperature, min: minTemp, max: maxTemp, iconCode: dailyWeather.iconCode)
        }
        delegate?.didUpdateWeatherData()
    }
}
