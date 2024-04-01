import Foundation

struct Weather: Codable {
    let id: Int
    let main: Main
    let description: Description
    let icon: String
}

enum Description: String, Codable {
    case brokenClouds = "broken clouds"
    case clearSky = "clear sky"
    case fewClouds = "few clouds"
    case lightRain = "light rain"
    case overcastClouds = "overcast clouds"
    case scatteredClouds = "scattered clouds"
}

enum Main: String, Codable {
    case clear = "Clear"
    case clouds = "Clouds"
    case rain = "Rain"
}
struct Temp: Codable {
    let day, min, max, night: Double
    let eve, morn: Double
}

struct WeatherData: Codable {
    let current: CurrentWeather
    let daily: [DailyWeather]
}

struct CurrentWeather: Codable {
    let temp: Double
    let weather: [Weather]
}

struct DailyWeather: Codable {
    let dt: Date
    let temp: Temp
    let weather: [Weather]
    var iconCode: String? {
      
        return weather.first?.icon
    }
}
struct Temperature: Codable {
    let day: Double
}

enum NetworkError: Error {
    case invalidURL
    case failedRequest
    case invalidResponse
}
