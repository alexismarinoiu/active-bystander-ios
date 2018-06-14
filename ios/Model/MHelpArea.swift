import Foundation

struct MHelpArea: Codable {
    let situation: String
    let situationId: Int
}

extension MHelpArea: Request {
    var resource: String {
        return "profile/helparea"
    }
}

struct MHelpAreaRequest: Encodable {
    let situation: String
    let situationId: Int
}

extension MHelpAreaRequest: Request {
    var resource: String {
        return "profile/helparea/\(situationId)"
    }
}
