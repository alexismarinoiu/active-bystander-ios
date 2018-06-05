import UIKit

protocol Request: Encodable {
    func getRequestParameters(for method: HTTPMethod) -> [String: CustomStringConvertible]
    func canRequestLogin(for method: HTTPMethod) -> Bool
    var endpoint: String { get }
}

extension Request {
    func getRequestParameters(for method: HTTPMethod) -> [String: CustomStringConvertible] {
        return [:]
    }

    func canRequestLogin(for method: HTTPMethod) -> Bool {
        return true
    }
}

typealias Response = Decodable

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct BackendServices {
    static func get<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
        where Req: Request, Res: Response {
        var urlRequest = URLRequest(url: makeURL(request, for: .get))
        urlRequest.httpMethod = HTTPMethod.get.rawValue

        perform(urlRequest: urlRequest, requestLogin: request.canRequestLogin(for: .get), callback: callback)
    }

    static func post<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
        where Req: Request, Res: Response {
        guard let urlRequest = makeJSONRequest(request, method: .post) else {
            callback(false, nil)
            return
        }
        perform(urlRequest: urlRequest, requestLogin: request.canRequestLogin(for: .post), callback: callback)
    }

    static func put<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
        where Req: Request, Res: Response {
        guard let urlRequest = makeJSONRequest(request, method: .put) else {
            callback(false, nil)
            return
        }
        perform(urlRequest: urlRequest, requestLogin: request.canRequestLogin(for: .put), callback: callback)
    }
}

// Utility Functions
extension BackendServices {
    static func makeURL<Req>(_ request: Req, for method: HTTPMethod) -> URL where Req: Request {
        var components = URLComponents(url: Environment.endpoint.appendingPathComponent(request.endpoint),
                                       resolvingAgainstBaseURL: false)!
        let queryItems = request.getRequestParameters(for: method).map {
            URLQueryItem(name: $0.key, value: $0.value.description)
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        return components.url!
    }

    static func makeJSONRequest<Req>(_ request: Req, method: HTTPMethod)
        -> URLRequest? where Req: Request {
        var urlRequest = URLRequest(url: makeURL(request, for: method))
        urlRequest.httpMethod = method.rawValue
        guard let encodedData = try? JSONEncoder().encode(request) else {
            return nil
        }

        urlRequest.httpBody = encodedData
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }

    static func perform<Res>(urlRequest request: URLRequest,
                             requestLogin login: Bool,
                             callback: @escaping (Bool, Res?) -> Void) where Res: Response {
        #if DEBUG
        print("Requesting: \(request.httpMethod ?? "not found") \(request.url?.absoluteString ?? "not found")")
        #endif

        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: request) { (data, status, error) in
            guard let http = status as? HTTPURLResponse,
                http.statusCode != 401 else { // Authorization Error
                if login {
                    DispatchQueue.main.async {
                        (UIApplication.shared.delegate as? AppDelegate)?.showLoginViewController()
                    }
                }
                callback(false, nil)
                return
            }

            guard error == nil,
                let data = data,
                let decodedData = try? JSONDecoder().decode(Res.self, from: data) else {
                    callback(false, nil)
                    return
            }

            callback(true, decodedData)
        }.resume()
    }
}
