import Foundation
import CoreLocation

struct MMapLocation: Codable {
    let latitude: Double
    let longitude: Double
    let helpAreas: [MHelpArea]
    let keyHelper: Bool

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
