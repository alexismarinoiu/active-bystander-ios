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

extension MLocation: Request {
    func getRequestParameters(for method: HTTPMethod) -> [String: CustomStringConvertible] {
        if method == .get {
            return [
                "latitude": latitude,
                "longitude": longitude,
                "username": username
            ]
        }

        return [:]
    }

    var endpoint: String {
        return "location"
    }
}

extension CLLocationCoordinate2D {
    func toMLocation(username: String) -> MLocation {
        return MLocation(latitude: latitude, longitude: longitude, username: username)
    }
}
