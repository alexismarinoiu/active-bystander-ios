import Foundation

struct MMessage: Codable {
    let sender: String
    let seq: Int
    let timeStamp: Date
    let content: String
    let threadId: String
}

extension MMessage: Request {
    func getRequestParameters(for method: HTTPMethod) -> [String : CustomStringConvertible] {
        if method == .get {
            return ["threadId": threadId]
        }

        return [:]
    }

    var endpoint: String {
        return "thread"
    }
}
