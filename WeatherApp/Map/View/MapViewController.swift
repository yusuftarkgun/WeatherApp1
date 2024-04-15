
import UIKit
import MapKit

final class MapViewController: UIViewController {

    @IBOutlet private weak var mapView: MKMapView!
    private var selectedLocation: CLLocationCoordinate2D?
    @IBOutlet private weak var updateButton: UIButton!
    var viewModel: MapViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addPin(_:)))
        mapView.addGestureRecognizer(longPressGesture)
        
        viewModel = MapViewModel(weatherService: WeatherService(), mapView: mapView)
        viewModel.delegate = self
    }
    
    @objc
    func addPin(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            let locationInView = gestureRecognizer.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            selectedLocation = locationOnMap
            viewModel.addAnnotation(at: locationOnMap)
        }
    }
    
    func setupUI() {
        mapView.delegate = self
    }
    
    @IBAction func didTapUpdateButton(_ sender: Any) {
        if let selectedLocation {
            NotificationCenter.default.post(name: NSNotification.Name.init("UpdateLocation"), object: selectedLocation)
        } else {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Ops!", message: "Something went wrong.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MKPointAnnotation {
            viewModel.fetchWeatherData(for: annotation.coordinate)
        }
    }
}

extension MapViewController: MapViewModelDelegate {
    func displayWeatherData(_ weatherData: WeatherData, at coordinate: CLLocationCoordinate2D) {
        let subtitle = "Sıcaklık: \(weatherData.current?.temp ?? 0)°C"
        viewModel.updateAnnotationSubtitle(subtitle)
    }
}
