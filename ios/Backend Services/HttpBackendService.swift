import UIKit

struct JSONInterchange: Interchange {
    let hasEmptyBody: Bool
}

struct URLInterchange: Interchange {
    public func getParameters(for type: CrudType) -> [String: CustomStringConvertible] {
        return [:]
    }
}

struct MultipartInterchange: Interchange {
    let file: URL
}

/// CRUD mappings correspond to the RESTful WS standard
struct HttpBackendService/*: BackendService notTODO: Genericise */{
    /// Maps HTTP method to their string representations
    ///
    /// - get: The HTTP GET method
    /// - post: The HTTP POST method
    /// - put: The HTTP PUT method
    /// - delete: The HTTP delete method
    enum HttpMethod: String {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
        case delete = "DELETE"

        var toCrud: CrudType {
            switch self {
            case .post:
                return .create
            case .get:
                return .read
            case .put:
                return .update
            case .delete:
                return .delete
            }
        }
    }

    // Due to ambiguity, there's a bit of duplication unfortunately
    // --- CREATE
    func create<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
        where Req: Request, Res: Response, Req.InterchangeType == JSONInterchange {
        guard var urlRequest = makeRequest(request, for: HttpMethod.post) else {
            callback(false, nil)
            return
        }
        let session = performSetupAuth(&urlRequest)
        let completionHandler = generateMakeTaskCallback(request: request, crudType: .create, callback: callback)
        session.dataTask(with: urlRequest, completionHandler: completionHandler).resume()
    }

    func create<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
        where Req: Request, Res: Response, Req.InterchangeType == URLInterchange {
        guard var urlRequest = makeRequest(request, for: HttpMethod.post) else {
            callback(false, nil)
            return
        }
        let session = performSetupAuth(&urlRequest)
        let completionHandler = generateMakeTaskCallback(request: request, crudType: .create, callback: callback)
        session.dataTask(with: urlRequest, completionHandler: completionHandler).resume()
    }

    func create<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
        where Req: Request, Res: Response, Req.InterchangeType == MultipartInterchange {
        guard var urlRequest = makeRequest(request, for: HttpMethod.post) else {
            callback(false, nil)
            return
        }

        let session = performSetupAuth(&urlRequest)
        let completionHandler = generateMakeTaskCallback(request: request, crudType: .create, callback: callback)
        session.uploadTask(with: urlRequest, fromFile: request.interchange.file,
                           completionHandler: completionHandler).resume()
    }

    // --- READ
    func read<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
        where Req: Request, Res: Response, Req.InterchangeType == JSONInterchange {
        guard var urlRequest = makeRequest(request, for: HttpMethod.get) else {
            callback(false, nil)
            return
        }
        let session = performSetupAuth(&urlRequest)
        let completionHandler = generateMakeTaskCallback(request: request, crudType: .read, callback: callback)
        session.dataTask(with: urlRequest, completionHandler: completionHandler).resume()
    }

    func read<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
        where Req: Request, Res: Response, Req.InterchangeType == URLInterchange {
        guard var urlRequest = makeRequest(request, for: HttpMethod.get) else {
            callback(false, nil)
            return
        }
        let session = performSetupAuth(&urlRequest)
        let completionHandler = generateMakeTaskCallback(request: request, crudType: .read, callback: callback)
        session.dataTask(with: urlRequest, completionHandler: completionHandler).resume()
    }

    func read<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
        where Req: Request, Res: Response, Req.InterchangeType == MultipartInterchange {
        guard var urlRequest = makeRequest(request, for: HttpMethod.get) else {
            callback(false, nil)
            return
        }

        let session = performSetupAuth(&urlRequest)
        let completionHandler = generateMakeTaskCallback(request: request, crudType: .read, callback: callback)
        session.uploadTask(with: urlRequest, fromFile: request.interchange.file,
                           completionHandler: completionHandler).resume()
    }

    // --- UPDATE
    func update<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
        where Req: Request, Res: Response, Req.InterchangeType == JSONInterchange {
        guard var urlRequest = makeRequest(request, for: HttpMethod.put) else {
            callback(false, nil)
            return
        }
        let session = performSetupAuth(&urlRequest)
        let completionHandler = generateMakeTaskCallback(request: request, crudType: .update, callback: callback)
        session.dataTask(with: urlRequest, completionHandler: completionHandler).resume()
    }

    func update<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
        where Req: Request, Res: Response, Req.InterchangeType == URLInterchange {
        guard var urlRequest = makeRequest(request, for: HttpMethod.put) else {
            callback(false, nil)
            return
        }
        let session = performSetupAuth(&urlRequest)
        let completionHandler = generateMakeTaskCallback(request: request, crudType: .update, callback: callback)
        session.dataTask(with: urlRequest, completionHandler: completionHandler).resume()
    }

    func update<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
        where Req: Request, Res: Response, Req.InterchangeType == MultipartInterchange {
        guard var urlRequest = makeRequest(request, for: HttpMethod.put) else {
            callback(false, nil)
            return
        }
        let session = performSetupAuth(&urlRequest)
        let completionHandler = generateMakeTaskCallback(request: request, crudType: .update, callback: callback)
        session.uploadTask(with: urlRequest, fromFile: request.interchange.file,
                           completionHandler: completionHandler).resume()
    }

    // --- DELETE
    func delete<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
        where Req: Request, Res: Response, Req.InterchangeType == JSONInterchange {
        guard var urlRequest = makeRequest(request, for: HttpMethod.delete) else {
            callback(false, nil)
            return
        }
        let session = performSetupAuth(&urlRequest)
        let completionHandler = generateMakeTaskCallback(request: request, crudType: .delete, callback: callback)
        session.dataTask(with: urlRequest, completionHandler: completionHandler).resume()
    }

    func delete<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
        where Req: Request, Res: Response, Req.InterchangeType == URLInterchange {
        guard var urlRequest = makeRequest(request, for: HttpMethod.delete) else {
            callback(false, nil)
            return
        }
        let session = performSetupAuth(&urlRequest)
        let completionHandler = generateMakeTaskCallback(request: request, crudType: .delete, callback: callback)
        session.dataTask(with: urlRequest, completionHandler: completionHandler).resume()
    }

    func delete<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
        where Req: Request, Res: Response, Req.InterchangeType == MultipartInterchange {
        guard var urlRequest = makeRequest(request, for: HttpMethod.delete) else {
            callback(false, nil)
            return
        }
        let session = performSetupAuth(&urlRequest)
        let completionHandler = generateMakeTaskCallback(request: request, crudType: .delete, callback: callback)
        session.uploadTask(with: urlRequest, fromFile: request.interchange.file,
                           completionHandler: completionHandler).resume()
    }
}

// Utility Functions
extension HttpBackendService {
    // JSON Interchange Request
    func makeRequest<Req: Request>(_ request: Req, for method: HttpMethod) -> URLRequest?
        where Req.InterchangeType == JSONInterchange {
        var urlRequest = URLRequest(url: Environment.endpoint.appendingPathComponent(request.resource))
        urlRequest.httpMethod = method.rawValue

        if !request.interchange.hasEmptyBody {
            guard let encodedData = try? JSONEncoder().encode(request) else {
                return nil
            }

            urlRequest.httpBody = encodedData
        } else {
            urlRequest.httpBody = "{}".data(using: .utf8)
        }

        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }

    // URL Interchange Request
    func makeRequest<Req: Request>(_ request: Req, for method: HttpMethod) -> URLRequest?
        where Req.InterchangeType == URLInterchange {
        var components = URLComponents(url: Environment.endpoint.appendingPathComponent(request.resource),
                                       resolvingAgainstBaseURL: false)!
        let queryItems = request.interchange.getParameters(for: method.toCrud).map {
            URLQueryItem(name: $0.key, value: $0.value.description)
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        var urlRequest = URLRequest(url: components.url!)
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }

    // URL Multipart Request
    func makeRequest<Req: Request>(_ request: Req, for method: HttpMethod) -> URLRequest?
        where Req.InterchangeType == MultipartInterchange {
        var urlRequest = URLRequest(url: Environment.endpoint.appendingPathComponent(request.resource))
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }

    private func performSetupAuth(_ urlRequest: inout URLRequest) -> URLSession {
        if !Environment.liveAuth, let username = Environment.userAuth.username {
            urlRequest.addValue(username, forHTTPHeaderField: "AV-User")
        }

        return URLSession(configuration: URLSessionConfiguration.default)
    }

    private func generateMakeTaskCallback<Req: Request, Res: Response>(request: Req, crudType: CrudType,
                                                                       callback: @escaping (Bool, Res?) -> Void)
        -> ((Data?, URLResponse?, Error?) -> Void) {
        return { [login = request.getCanRequestLogin(for: crudType)] (data, status, error) in

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
        }
    }

    private func perform<Req: Request, Res: Response>(_ urlRequest: inout URLRequest, request: Req,
                                                      crudType: CrudType, callback: @escaping (Bool, Res?) -> Void)
        where Req.InterchangeType == MultipartInterchange {
        let session = performSetupAuth(&urlRequest)
        let completionHandler = generateMakeTaskCallback(request: request, crudType: crudType, callback: callback)
        session.uploadTask(with: urlRequest, fromFile: request.interchange.file,
                           completionHandler: completionHandler).resume()
    }

}
