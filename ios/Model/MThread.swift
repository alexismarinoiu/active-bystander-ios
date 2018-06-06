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

extension MThread: Request {
    func getRequestParameters(for method: HTTPMethod) -> [String : CustomStringConvertible] {
        if method == .get {
            return [:]
        }

        return [:]
    }

    var endpoint: String {
        return "thread"
    }
}


