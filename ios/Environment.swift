import Foundation

struct Environment {
    private init() {}

    static var endpoint: URL = {
        // swiftlint:disable force_cast
        return URL(string: Bundle.main.infoDictionary!["AV_API_ENDPOINT"] as! String)!
        // swiftlint:enable force_cast
    }()

    static var base: URL = {
        // swiftlint:disable force_cast
        return URL(string: Bundle.main.infoDictionary!["AV_API_BASE"] as! String)!
        // swiftlint:enable force_cast
    }()

    static var realm: String = {
        // swiftlint:disable force_cast
        return Bundle.main.infoDictionary!["AV_API_AUTHENTICATION_REALM"] as! String
        // swiftlint:enable force_cast
    }()

    static var liveAuth: Bool = {
        // swiftlint:disable force_cast
        return (Bundle.main.infoDictionary!["AV_API_LIVE_AUTH"] as! String).lowercased() == "yes"
        // swiftlint:enable force_cast
    }()

    static var userAuth = UserAuth()
    static var backend: BackendService = HttpBackendService()
}
