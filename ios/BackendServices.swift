import Foundation

protocol Request: Encodable {
    var requestParameters: [String: CustomStringConvertible] { get }
    var endpoint: String { get }
}

extension Request {
    var requestParameters: [String: CustomStringConvertible] {
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
        var urlRequest = URLRequest(url: makeURL(request))
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
    static func makeURL<Req>(_ request: Req) -> URL where Req: Request {
        var components = URLComponents(url: Environment.endpoint.appendingPathComponent(request.endpoint),
                                       resolvingAgainstBaseURL: false)!
        components.queryItems = request.requestParameters.map {
            URLQueryItem(name: $0.key, value: $0.value.description)
        }
        return components.url!
    }

    static func makeJSONRequest<Req>(_ request: Req, method: HTTPMethod)
        -> URLRequest? where Req: Request {
        var urlRequest = URLRequest(url: makeURL(request))
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
