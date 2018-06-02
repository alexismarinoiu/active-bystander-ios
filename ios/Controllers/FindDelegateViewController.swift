import UIKit
import MapKit
import CoreLocation

class FindDelegateViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet weak var connectButtonBottomConstraint: NSLayoutConstraint!
    private var connectButtonHidden: Bool = true

    /// Viewport specified in metres
    private let viewport: CLLocationDistance = 70
    private static let helperMarkerIdent = "marker"

    private var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        connectButton.layer.cornerRadius = 5

        mapView.layoutMargins = mapView.safeAreaInsets
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: FindDelegateViewController.helperMarkerIdent)

        // -- Set up the location manager --
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        // Track the location if it's changing
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FindDelegateViewController {

    private func updateOtherUsersOnMap(locations: [MLocation]) {
        let annotations = locations.map { (location: MLocation) -> MKAnnotation in
            let point = MKPointAnnotation()
            point.coordinate = location.coordinate
            return point
        }
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
    }

    private func showConnectButton() {
        guard connectButtonHidden else {
            return
        }

        let savedConstant = connectButtonBottomConstraint.constant
        connectButtonBottomConstraint.constant = 0
        view.layoutIfNeeded()
        connectButtonBottomConstraint.constant = savedConstant
        self.connectButton.isHidden = false
        self.connectButton.isOpaque = false
        self.connectButton.layer.opacity = 0

        UIView.animate(withDuration: 0.5, animations: {
            self.connectButton.layer.opacity = 1
            self.connectButton.isOpaque = true
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.connectButtonHidden = false
        })
    }

    private func hideConnectButton() {
        guard !connectButtonHidden else {
            return
        }

        let savedConstant = connectButtonBottomConstraint.constant
        view.layoutIfNeeded()
        connectButtonBottomConstraint.constant = 0
        self.connectButton.isOpaque = false
        self.connectButton.layer.opacity = 1

        UIView.animate(withDuration: 0.5, animations: {
            self.connectButton.layer.opacity = 0
            self.connectButton.isOpaque = true
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.connectButtonBottomConstraint.constant = savedConstant
            self.connectButton.isHidden = true
            self.connectButtonHidden = true
        })
    }

}

// MARK: - CLLocationManagerDelegate
extension FindDelegateViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, viewport, viewport)
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()

        BackendServices.get(location.coordinate.toMLocation(username: "nv516")) { (success, locations: [MLocation]?) in
            guard success, let locations = locations else {
                // notTODO: Handle error, perhaps a periodic refresh?
                return
            }

            DispatchQueue.main.async {
                self.updateOtherUsersOnMap(locations: locations)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedAlways {
            locationManager.requestWhenInUseAuthorization()
        }

        locationManager.startUpdatingLocation()
    }
}

// MARK: - MKMapViewDelegate
extension FindDelegateViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // A cluster annotation
        if let cluster = annotation as? MKClusterAnnotation,
            let marker =
             mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier,
                                                   for: cluster) as? MKMarkerAnnotationView {
            marker.animatesWhenAdded = false
            marker.markerTintColor = .darkGray
            return marker
        }

        // A non-cluster (Helper) annotation
        if let point = annotation as? MKPointAnnotation,
            let marker =
                mapView.dequeueReusableAnnotationView(withIdentifier: FindDelegateViewController.helperMarkerIdent,
                                                      for: point) as? MKMarkerAnnotationView {
            marker.clusteringIdentifier = MKMapViewDefaultClusterAnnotationViewReuseIdentifier
            marker.animatesWhenAdded = true
            marker.markerTintColor = .black
            marker.glyphText = "☻"
            marker.layer.cornerRadius = 100
            return marker
        }

        return nil
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let cluster = view.annotation as? MKClusterAnnotation {
            mapView.deselectAnnotation(cluster, animated: false)
            let span = mapView.region.span
            let newSpan = MKCoordinateSpanMake(span.latitudeDelta / 1.5, span.longitudeDelta / 1.5)
            let region = MKCoordinateRegion(center: cluster.coordinate, span: newSpan)
            mapView.setRegion(region, animated: true)
            return
        }

        if view.annotation is MKPointAnnotation {
            showConnectButton()
        }
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.annotation is MKPointAnnotation {
            hideConnectButton()
        }
    }
}

// MARK: - Temporary CLLocationCoordinate2D to add coordinates
extension CLLocationCoordinate2D {
    static func + (_ lhs: CLLocationCoordinate2D, _ rhs: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(lhs.latitude + rhs.latitude, lhs.longitude + rhs.longitude)
    }
}
