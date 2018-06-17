import UIKit

enum CrudType {
    case create, read, update, delete
}

// Payload interchange format
protocol Interchange { }

protocol Request: Encodable {
    associatedtype InterchangeType: Interchange

    var resource: String { get }
    var interchange: InterchangeType { get }
}

extension Request {
    func getCanRequestLogin(for type: CrudType) -> Bool {
        return true
    }
}

typealias Response = Decodable

//protocol BackendService {
//    // CRUD Request Types
//    func create<Req: Request, Res: Response>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
//    func read<Req: Request, Res: Response>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
//    func update<Req: Request, Res: Response>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
//    func delete<Req: Request, Res: Response>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
//}
