import Foundation

struct MThread: Codable {
    let threadId: String
    let status: Status
    let title: String

    enum Status: String, Codable {
        case accepted = "ACCEPTED"
        case holding = "HOLDING"
    }
}

struct MThreadRequest: Encodable {}

extension MThreadRequest: Request {
    var resource: String {
        return "thread"
    }
}

struct MThreadConnectRequest: Encodable {
    let latitude: Double
    let longitude: Double
    let username: String
}

extension MThreadConnectRequest: Request {
    var resource: String {
        return "thread"
    }
}
