import Foundation
import CoreLocation

struct MLocation: Codable {
    let latitude: Double
    let longitude: Double
    let username: String
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension MLocation: URLParamable {
    var asURLParams: String {
        return "latitude=\(latitude)&longitude=\(longitude)&username=\(username)"
    }
}

extension MLocation: Endpointable {
    var endpoint: String { return "location" }
}

extension CLLocationCoordinate2D {
    func toMLocation(username: String) -> MLocation {
        return MLocation(latitude: latitude, longitude: longitude, username: username)
    }
}
