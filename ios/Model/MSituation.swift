import Foundation
import CoreLocation

struct MSituationRequest: Encodable {
}

extension MSituationRequest: Request {
    var resource: String {
        return "situation"
    }
}

struct MSituation: Decodable {
    let title: String
    let html: String?
    let children: [MSituation]
}
