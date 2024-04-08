import Foundation
import CoreLocation
import Foundation

protocol WeatherViewModelDelegate: AnyObject {
    func didUpdateWeatherData()
    func didFailWithError(_ error: Error)
}

final class WeatherViewModel {
    weak var delegate: WeatherViewModelDelegate?
    
    var currentTemperature: String = ""
    var currentIconCode: String = ""
    var sevenDayForecast: [WeatherForecast]?
    
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
    
    private func processWeatherData(_ weatherData: WeatherData?) {
        guard let weatherData else { return }
        currentTemperature = "\(Int(weatherData.current?.temp ?? 0))°C"
        if let currentWeather = weatherData.current?.weather?.first {
            currentIconCode = currentWeather.icon ?? ""
        }
        sevenDayForecast = weatherData.daily.map { dailyWeather in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let date = dateFormatter.string(from: dailyWeather.dt ?? Date())
            let temperature = "\(Int(dailyWeather.temp?.day ?? 0))°C"
            let minTemp = "\(Int(dailyWeather.temp?.min ?? 0))°C"
            let maxTemp = "\(Int(dailyWeather.temp?.max ?? 0))°C"
            let iconCode = dailyWeather.iconCode
                
            return WeatherForecast(date: date, temperature: temperature, min: minTemp, max: maxTemp, iconCode: iconCode)
        }
        delegate?.didUpdateWeatherData()
    }
}
