import Foundation

struct MThread: Codable {
    let threadId: String
    let status: Status
    let title: String
    let creator: Bool
    let threadImage: String?

    enum Status: String, Codable {
        case accepted = "ACCEPTED"
        case holding = "HOLDING"
    }
}

extension MThread: Equatable {
    static func == (_ lhs: MThread, _ rhs: MThread) -> Bool {
        return lhs.status == rhs.status && lhs.threadId == rhs.threadId && lhs.title == rhs.title
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
