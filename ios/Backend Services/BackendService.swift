import UIKit

enum CrudType {
    case create, read, update, delete
}

protocol Request: Encodable {
    var resource: String { get }

    func getParameters(for type: CrudType) -> [String: CustomStringConvertible]
    func getCanRequestLogin(for type: CrudType) -> Bool // notTODO: Perhaps move this out to an attribute dictionary
    func hasEmptyBody(for type: CrudType) -> Bool
}

extension Request {
    func getParameters(for type: CrudType) -> [String: CustomStringConvertible] {
        return [:]
    }

    func getCanRequestLogin(for type: CrudType) -> Bool {
        return true
    }

    func hasEmptyBody(for type: CrudType) -> Bool {
        return false
    }
}

typealias Response = Decodable

protocol BackendService {
    // CRUD Request Types
    func create<Req: Request, Res: Response>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
    func read<Req: Request, Res: Response>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
    func update<Req: Request, Res: Response>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
    func delete<Req: Request, Res: Response>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
}
