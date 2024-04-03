import UIKit
import MapKit

class MapViewController: UIViewController {
    var selectedCoordinate: CLLocationCoordinate2D?
    let weatherService = WeatherService()
    var annotations: [MKAnnotation] = []

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var updateWeatherButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressGesture)
    }

    func setupUI() {
        mapView.delegate = self
    }

    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            let locationInView = gestureRecognizer.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            
            // Mevcut pinleri sil
            mapView.removeAnnotations(annotations)
            annotations.removeAll()
            addAnnotation(at: locationOnMap)
            selectedCoordinate = locationOnMap
        }
    }

    func addAnnotation(at coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        annotations.append(annotation)
    }

    @IBAction func updateWeatherButtonTapped(_ sender: UIButton) {
        guard let coordinate = selectedCoordinate else {
            // Eğer bir koordinat seçilmemişse işlemi sonlandır
            return
        }
        
        // Hava durumu verilerini güncellemek için servise koordinatı gönder
        weatherService.fetchWeatherData(for: coordinate) { result in
            switch result {
            case .success(let weatherData):
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("DidSelectMapLocation"), object: nil, userInfo: ["weatherData": weatherData])
                    NotificationCenter.default.post(name: Notification.Name("DidSelectMapLocation"), object: nil, userInfo: ["coordinate": coordinate])

                }
            case .failure(let error):
                print("Hava durumu güncellenirken hata oluştu: \(error)")
            }
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    // Harita üzerinde bir pin seçildiğinde, seçilen koordinatı sakla
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            selectedCoordinate = annotation.coordinate
        }
    }
}


