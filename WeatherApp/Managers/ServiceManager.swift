import Foundation
import CoreLocation

class WeatherService {
    static let shared = WeatherService()
    private let apiKey = "8ddadecc7ae4f56fee73b2b405a63659"
    
    func fetchWeatherData(for coordinate: CLLocationCoordinate2D, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&exclude=minutely,hourly&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(NetworkError.failedRequest))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let weatherData = try decoder.decode(WeatherData.self, from: data)
                completion(.success(weatherData))
            } catch {
                completion(.failure(NetworkError.invalidResponse))
            }
        }.resume()
    }
}
