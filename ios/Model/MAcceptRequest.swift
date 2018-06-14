import Foundation

struct MAcceptRequest: Codable {

    let threadId: String

    init(_ threadId: String) {
        self.threadId = threadId
    }

    func encode(to encoder: Encoder) throws {
    }
}

extension MAcceptRequest: Request {

    var resource: String {
        return "thread/\(threadId)/accept"
    }
}
