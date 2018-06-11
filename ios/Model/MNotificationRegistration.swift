import Foundation

struct MNotificationRegistration: Codable {
    let token: String
}

extension MNotificationRegistration: Request {
    var resource: String {
        return "notification/register"
    }
}
