import Foundation

struct MProfileRequest: Encodable {
}

extension MProfileRequest: Request {
    var resource: String {
        return "profile"
    }
}

struct MProfile: Codable {
    let username: String
    let displayName: String
    let profileImage: String?
    let helpAreas: [MHelpArea]
}
