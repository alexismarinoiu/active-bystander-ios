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
    // swiftlint:disable identifier_name
    let id: Int
    // swiftlint:enable identifier_name
    let title: String
    let html: String?
    let children: [MSituation]
}
