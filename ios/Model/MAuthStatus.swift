import Foundation

struct AuthStatusRequest: Encodable { }

extension AuthStatusRequest: Request {
    var endpoint: String {
        return "status"
    }

    func canRequestLogin(for method: HTTPMethod) -> Bool {
        return false
    }
}

struct AuthStatusResponse: Decodable {
    let status: Bool
    let username: String
}
