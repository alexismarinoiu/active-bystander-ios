//
//  ViewController.swift
//  ios
//
//  Created by Nik on 23/05/2018.
//  Copyright © 2018 avocado. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class FindDelegateViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    private static let viewport = MKCoordinateSpanMake(0.01, 0.01)
    
    private var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.startUpdatingLocation()

        mapView.showsUserLocation = true

        // Register with the location service to update the map and the user's location when it changes
        locationManager.requestAlwaysAuthorization()
        focus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FindDelegateViewController {
    private func focus() {
        if let location = locationManager.location {
            focus(on: location)
        }
    }
    
    private func focus(on location: CLLocation) {
        let region = MKCoordinateRegionMake(location.coordinate,
                                            FindDelegateViewController.viewport)
        mapView.setRegion(region, animated: true)
    }
}

extension FindDelegateViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // We will use this method later to store and dispatch locations so that users may find eachother etc
        focus()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
        
        focus()
    }
}
