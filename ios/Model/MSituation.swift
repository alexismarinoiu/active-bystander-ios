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
    let situation: String
    let html: String
    let group: String?
}
