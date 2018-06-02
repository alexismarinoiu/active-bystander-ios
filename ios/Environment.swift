import Foundation

struct Environment {
    private init() {}
    
    static var endpoint: URL = {
        return URL(string: Bundle.main.infoDictionary!["AV_API_ENDPOINT"] as! String)!
    }()
}
