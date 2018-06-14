import Foundation

struct MAcceptRequest: Encodable {

    let threadId: String

    init(_ threadId: String) {
        self.threadId = threadId
    }
}

extension MAcceptRequest: Request {

    var resource: String {
        return "thread/\(threadId)/accept"
    }

    func hasEmptyBody(for type: CrudType) -> Bool {
        return true
    }
}
