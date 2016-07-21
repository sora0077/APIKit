import Foundation

/// `ResponseError` represents a common error that occurs while getting `RequestType.Response`
/// from raw result tuple `(Data?, URLResponse?, NSError?)`.
public enum ResponseError: ErrorProtocol {
    /// Indicates the session adapter returned `URLResponse` that fails to down-cast to `HTTPURLResponse`.
    case nonHTTPURLResponse(URLResponse?)

    /// Indicates `HTTPURLResponse.statusCode` is not acceptable.
    /// In most cases, *acceptable* means the value is in `200..<300`.
    case unacceptableStatusCode(Int)

    /// Indicates `AnyObject` that represents the response is unexpected.
    case unexpectedObject(AnyObject)
}
