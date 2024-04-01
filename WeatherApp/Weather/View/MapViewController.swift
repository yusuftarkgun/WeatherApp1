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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    func setupUI(){
        mapView.delegate = self
    }
}

extension MapViewController: MKMapViewDelegate {
    
}
