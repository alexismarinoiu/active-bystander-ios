import Foundation

struct MMessageRequest: Encodable {
    let threadId: String
    let queryLastMessage: Bool

    init(threadId: String, queryLastMessage: Bool) {
        self.threadId = threadId
        self.queryLastMessage = queryLastMessage
    }
}

extension MMessageRequest: Request {
    typealias InterchangeType = JSONInterchange

    var resource: String {
        return queryLastMessage ? "thread/\(threadId)/last-message" : "thread/\(threadId)"
    }

    var interchange: JSONInterchange {
        return JSONInterchange(hasEmptyBody: true)
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
    typealias InterchangeType = JSONInterchange

    var resource: String {
        return "thread/\(threadId)"
    }

    var interchange: JSONInterchange {
        return JSONInterchange(hasEmptyBody: false)
    }
}
