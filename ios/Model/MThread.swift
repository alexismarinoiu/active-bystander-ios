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

    func getRequestParameters(for type: CrudType) -> [String: CustomStringConvertible] {
        if type == .read {
            return [:]
        }

        return [:]
    }

}
