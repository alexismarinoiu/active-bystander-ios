import Foundation

struct MHelpArea: Codable {
    let situation: String
    let situationId: Int
}

struct MHelpAreaRequest: Encodable {
    let situation: String
    let situationId: Int
}

extension MHelpAreaRequest: Request {
    var resource: String {
        return "profile/helparea"
    }

    func getParameters(for type: CrudType) -> [String: CustomStringConvertible] {
        if type == .create {
            return [
                "situation": situation,
                "situationId": situationId
            ]
        }

        return [:]
    }
}
