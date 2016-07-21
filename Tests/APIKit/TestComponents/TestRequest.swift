import Foundation
import APIKit

struct TestRequest: RequestType {
    var absoluteURL: URL? {
        let URLRequest = try? buildURLRequest()
        return URLRequest?.url
    }

    // MARK: RequestType
    typealias Response = AnyObject

    init(baseURL: String = "https://example.com", path: String = "/", method: HTTPMethod = .GET, parameters: AnyObject? = [:], headerFields: [String: String] = [:], interceptURLRequest: (URLRequest) throws -> URLRequest = { $0 }) {
        self.baseURL = URL(string: baseURL)!
        self.path = path
        self.method = method
        self.parameters = parameters
        self.headerFields = headerFields
        self.interceptURLRequest = interceptURLRequest
    }

    let baseURL: URL
    let method: HTTPMethod
    let path: String
    let parameters: AnyObject?
    let headerFields: [String: String]
    let interceptURLRequest: (URLRequest) throws -> URLRequest

    func interceptURLRequest(_ URLRequest: URLRequest) throws -> URLRequest {
        return try interceptURLRequest(URLRequest)
    }

    func responseFromObject(_ object: AnyObject, URLResponse: HTTPURLResponse) throws -> Response {
        return object
    }
}
