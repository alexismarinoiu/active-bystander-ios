import Foundation

struct MMessage: Codable {
    let sender: String
    let seq: Int
    let timeStamp: Date
    let content: String
    let threadId: String
}

struct MMessageRequest: Encodable {
    let threadId: String

    init(threadId: String) {
        self.threadId = threadId
    }

    func encode(to encoder: Encoder) throws {
    }
}

extension MMessageRequest: Request {
    var endpoint: String {
        return "thread/\(threadId)"
    }
}
