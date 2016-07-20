import Foundation

/// `RequestError` represents a common error that occurs while building `NSURLRequest` from `RequestType`.
public enum RequestError: ErrorProtocol {
    /// Indicates `baseURL` of a type that conforms `RequestType` is invalid.
    case invalidBaseURL(URL)

    /// Indicates `NSURLRequest` built by `RequestType.buildURLRequest` is unexpected.
    case unexpectedURLRequest(URLRequest)
}
