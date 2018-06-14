import Foundation

struct MDeclineRequest: Encodable {

    let threadId: String

    init(_ threadId: String) {
        self.threadId = threadId
    }
}

extension MDeclineRequest: Request {

    var resource: String {
        return "thread/\(threadId)/decline"
    }

    func hasEmptyBody(for type: CrudType) -> Bool {
        return true
    }
}
