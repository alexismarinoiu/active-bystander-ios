import Foundation

typealias RequestType = Encodable & URLParamable & Endpointable
typealias ResponseType = Decodable

struct BackendServices {
    static func get<RequestT, ResponseT>(_ request: RequestT, callback: @escaping (Bool, ResponseT?) -> Void)
        where RequestT: RequestType, ResponseT: ResponseType
    {
        var components = URLComponents(url: Environment.endpoint.appendingPathComponent(request.endpoint),
                                       resolvingAgainstBaseURL: false)!
        components.query = request.asURLParams

        var urlRequest = URLRequest(url: components.url!)
        urlRequest.httpMethod = HTTPMethod.get.rawValue

        perform(urlRequest: urlRequest, callback: callback)
    }

    static func post<RequestT, ResponseT>(_ request: RequestT, callback: @escaping (Bool, ResponseT?) -> Void)
        where RequestT: RequestType, ResponseT: ResponseType
    {
        guard let urlRequest = makeJSONRequest(request, method: .post) else {
            callback(false, nil)
            return
        }
        perform(urlRequest: urlRequest, callback: callback)
    }
    
    static func put<RequestT, ResponseT>(_ request: RequestT, callback: @escaping (Bool, ResponseT?) -> Void)
        where RequestT: RequestType, ResponseT: ResponseType
    {
        guard let urlRequest = makeJSONRequest(request, method: .put) else {
            callback(false, nil)
            return
        }
        perform(urlRequest: urlRequest, callback: callback)
    }
}

// Utility Functions
extension BackendServices {
    static func makeJSONRequest<RequestT>(_ request: RequestT, method: HTTPMethod) -> URLRequest? where RequestT: RequestType {
        var urlRequest = URLRequest(url: Environment.endpoint.appendingPathComponent(request.endpoint))
        urlRequest.httpMethod = method.rawValue
        guard let encodedData = try? JSONEncoder().encode(request) else {
            return nil
        }
        
        urlRequest.httpBody = encodedData
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
    
    static func perform<ResponseT>(urlRequest request: URLRequest, callback: @escaping (Bool, ResponseT?) -> Void)
        where ResponseT: ResponseType
    {
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil,
                let data = data,
                let decodedData = try? JSONDecoder().decode(ResponseT.self, from: data) else {
                    callback(false, nil)
                    return
            }

            callback(true, decodedData)
        }.resume()
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol URLParamable {
    var asURLParams: String { get }
}

protocol Endpointable {
    var endpoint: String { get }
}
