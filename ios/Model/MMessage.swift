import Foundation

struct MMessage: Codable {
    let sender: String
    let seq: Int
    let timestamp: String
    let content: String
    let threadId: String
}

struct MMessageRequest: Encodable {
    let threadId: String
    let flag: Bool

    init(threadId: String, flag: Bool) {
        self.threadId = threadId
        self.flag = flag
    }

    func encode(to encoder: Encoder) throws {
    }
}

extension MMessageRequest: Request {
    var resource: String {
        return flag ? "thread/\(threadId)/last-message" : "thread/\(threadId)"
    }

}
