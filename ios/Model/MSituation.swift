import Foundation
import CoreLocation

struct MSituationRequest: Encodable {
}

extension MSituationRequest: Request {
    var endpoint: String {
        return "situation"
    }
}

struct MSituation: Decodable {
    // swiftlint:disable identifier_name
    let id: String
    // swiftlint:enable identifier_name
    let html: String
}
