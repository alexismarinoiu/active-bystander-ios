import Foundation

struct MDeclineRequest: Encodable {

    let threadId: String

    init(_ threadId: String) {
        self.threadId = threadId
    }
}

extension MDeclineRequest: Request {

    typealias InterchangeType = JSONInterchange

    var resource: String {
        return "thread/\(threadId)/decline"
    }

    var interchange: JSONInterchange {
        return JSONInterchange(hasEmptyBody: true)
    }
}
