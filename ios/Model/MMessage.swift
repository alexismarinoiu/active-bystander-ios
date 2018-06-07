import Foundation

struct MMessageRequest: Encodable {
    let threadId: String
    let queryLastMessage: Bool

    init(threadId: String, queryLastMessage: Bool) {
        self.threadId = threadId
        self.queryLastMessage = queryLastMessage
    }

    func encode(to encoder: Encoder) throws {
    }
}

extension MMessageRequest: Request {
    var resource: String {
        return queryLastMessage ? "thread/\(threadId)/last-message" : "thread/\(threadId)"
    }
}

struct MMessage: Codable {
    let sender: String
    let seq: Int
    let timestamp: String
    let content: String
    let threadId: String
}

struct MMessageSendRequest: Encodable {
    let seq: Int
    let content: String

    let threadId: String // notTODO: Ensure that this does not get encoded
}

extension MMessageSendRequest: Request {
    var resource: String {
        return "thread/\(threadId)"
    }
}
