import Foundation
import UIKit
import MapKit

protocol MapViewModelDelegate: AnyObject {
    func displayWeatherData(_ weatherData: WeatherData, at coordinate: CLLocationCoordinate2D)
}

final class MapViewModel {
    
    weak var delegate: MapViewModelDelegate?
    private let weatherService: WeatherService
    private let mapView: MKMapView
    
    var selectedAnnotation: MKPointAnnotation?
    
    init(weatherService: WeatherService, mapView: MKMapView) {
        self.weatherService = weatherService
        self.mapView = mapView
    }
    
    func addAnnotation(at coordinate: CLLocationCoordinate2D) {
        if let existingAnnotation = selectedAnnotation {
            mapView.removeAnnotation(existingAnnotation)
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        selectedAnnotation = annotation
        
        weatherService.fetchWeatherData(for: coordinate) { result in
            switch result {
            case .success(let weatherData):
                DispatchQueue.main.async {
                    self.delegate?.displayWeatherData(weatherData, at: coordinate)
                }
            case .failure(let error):
                print("Hava durumu bilgileri alınamadı:", error)
            }
        }
    }
    
    func fetchWeatherData(for coordinate: CLLocationCoordinate2D) {
        weatherService.fetchWeatherData(for: coordinate) { result in
            switch result {
            case .success(let weatherData):
                DispatchQueue.main.async {
                    self.delegate?.displayWeatherData(weatherData, at: coordinate)
                }
            case .failure(let error):
                print("Hava durumu bilgileri alınamadı:", error)
            }
        }
    }
    
    func updateAnnotationSubtitle(_ subtitle: String) {
        selectedAnnotation?.subtitle = subtitle
    }
}
