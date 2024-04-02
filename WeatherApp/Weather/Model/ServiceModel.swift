//
//  ServiceModel.swift
//  WeatherApp
//
//  Created by Yusuf Tarık Gün on 28.03.2024.
import Foundation


// MARK: - Temp
struct Temp: Codable {
    let day, min, max, night: Double
}

// MARK: - Weather
struct Weather: Codable {
    let id: Int?
    let main: String?
    let description: String?
    let icon: String?
    
    enum CodingKeys: CodingKey {
        case id
        case main
        case description
        case icon
    }
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
