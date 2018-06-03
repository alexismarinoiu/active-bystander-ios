import Foundation

protocol Request: Encodable {
    func getRequestParameters(for method: HTTPMethod) -> [String: CustomStringConvertible]
    var endpoint: String { get }
}

extension Request {
    func getRequestParameters(for method: HTTPMethod) -> [String: CustomStringConvertible] {
        return [:]
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

        perform(urlRequest: urlRequest, callback: callback)
    }

    static func post<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
        where Req: Request, Res: Response {
        guard let urlRequest = makeJSONRequest(request, method: .post) else {
            callback(false, nil)
            return
        }
        perform(urlRequest: urlRequest, callback: callback)
    }

    static func put<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
        where Req: Request, Res: Response {
        guard let urlRequest = makeJSONRequest(request, method: .put) else {
            callback(false, nil)
            return
        }
        perform(urlRequest: urlRequest, callback: callback)
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

    static func perform<Res>(urlRequest request: URLRequest, callback: @escaping (Bool, Res?) -> Void)
        where Res: Response {
        URLSession.shared.dataTask(with: request) { (data, _, error) in
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
