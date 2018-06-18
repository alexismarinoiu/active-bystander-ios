import Foundation

struct AuthStatusRequest: Encodable { }

extension AuthStatusRequest: Request {
    var resource: String {
        return "status"
    }

    func getCanRequestLogin(for type: CrudType) -> Bool {
        return false
    }
}

struct AuthStatusResponse: Decodable {
    let status: Bool
    let username: String
}
