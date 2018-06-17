import Foundation
import CoreLocation

struct MMapLocation: Codable {
    let latitude: Double
    let longitude: Double
    let username: String
    let helpAreas: [MHelpArea]

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
