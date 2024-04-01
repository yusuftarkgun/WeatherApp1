//
//  MapViewController.swift
//  WeatherApp
//
//  Created by Yusuf Tarık Gün on 1.04.2024.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
        var selectedAnnotation: MKPointAnnotation?
        let weatherService = WeatherService()

        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addPin(_:)))
            mapView.addGestureRecognizer(longPressGesture)
        }
        
        @objc func addPin(_ gestureRecognizer: UILongPressGestureRecognizer) {
            if gestureRecognizer.state == .ended {
                let locationInView = gestureRecognizer.location(in: mapView)
                let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
                if let existingAnnotation = selectedAnnotation {
                    mapView.removeAnnotation(existingAnnotation)
                }
                let annotation = MKPointAnnotation()
                annotation.coordinate = locationOnMap
                mapView.addAnnotation(annotation)
                selectedAnnotation = annotation
                weatherService.fetchWeatherData(for: locationOnMap) { result in
                    switch result {
                    case .success(let weatherData):
                        DispatchQueue.main.async {
                            self.displayWeatherData(weatherData, at: locationOnMap)
                        }
                    case .failure(let error):
                        print("Hava durumu bilgileri alınamadı:", error)
                    }
                }
            }
        }
        
        func displayWeatherData(_ weatherData: WeatherData, at coordinate: CLLocationCoordinate2D) {
            let subtitle = "Sıcaklık: \(weatherData.current.temp)°C"
            selectedAnnotation?.subtitle = subtitle
        }
        
        func setupUI() {
            mapView.delegate = self
        }
    }

    extension MapViewController: MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? MKPointAnnotation {
                print("Tıklanan pinin koordinatları: \(annotation.coordinate)")
                weatherService.fetchWeatherData(for: annotation.coordinate) { result in
                    switch result {
                    case .success(let weatherData):
                        DispatchQueue.main.async {
                            self.displayWeatherData(weatherData, at: annotation.coordinate)
                        }
                    case .failure(let error):
                        print("Hava durumu bilgileri alınamadı:", error)
                    }
                }
            }
        }
    }
