import Foundation

struct Environment {
    private init() {}

    static var endpoint: URL = {
        // swiftlint:disable force_cast
        return URL(string: Bundle.main.infoDictionary!["AV_API_ENDPOINT"] as! String)!
        // swiftlint:enable force_cast
    }()
}
