import Foundation

//#if IS_STAGING
private let apiUrl = URL(string: "https://av3.vangerow.uk/staging")!
//#else
//private let apiUrl = URL(string: "https://av3.vangerow.uk/production")!
//#endif

enum RequestType {
    case location
}

protocol Request {
    associatedtype RequestType
    associatedtype ResponseType

    func get(_ request: RequestType, callback: @escaping (Bool, ResponseType) -> Void)
    func post(_ request: RequestType, callback: @escaping (Bool, ResponseType) -> Void)
}

struct LocationRequest: Request {
    typealias RequestType = MLocation
    typealias ResponseType = [MLocation]

    func get(_ request: MLocation, callback: @escaping (Bool, [MLocation]) -> Void) {
        // TODO: Improve this
        var components = URLComponents(url: apiUrl.appendingPathComponent("location"), resolvingAgainstBaseURL: false)!
        components.query = "latitude=\(request.latitude)&longitude=\(request.longitude)&username=\(request.username)"
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                callback(false, [])
                return
            }
            
            guard let data = data else {
                return
            }
            
            let locations = try! JSONDecoder().decode([MLocation].self, from: data)
            callback(true, locations)
        }.resume()
    }
    
    func post(_ request: MLocation, callback: @escaping (Bool, [MLocation]) -> Void) {
        var urlRequest = URLRequest(url: apiUrl.appendingPathComponent("location"))
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try! JSONEncoder().encode(request)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                callback(false, [])
            }
            callback(true, [])
        }.resume()
    }
}

class BackendServices {
    func get<T: Request>(_ request: T, data: T.RequestType, callback: @escaping (Bool, T.ResponseType) -> Void) {
        return request.get(data, callback: callback)
    }
    
    func post<T: Request>(_ request: T, data: T.RequestType, callback: @escaping (Bool, T.ResponseType) -> Void) {
        return request.post(data, callback: callback)
    }
}

