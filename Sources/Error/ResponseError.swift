import Foundation

/// `ResponseError` represents a common error that occurs while getting `RequestType.Response`
/// from raw result tuple `(NSData?, NSURLResponse?, NSError?)`.
public enum ResponseError: ErrorProtocol {
    /// Indicates the session adapter returned `NSURLResponse` that fails to down-cast to `NSHTTPURLResponse`.
    case nonHTTPURLResponse(URLResponse?)

    /// Indicates `NSHTTPURLResponse.statusCode` is not acceptable.
    /// In most cases, *acceptable* means the value is in `200..<300`.
    case unacceptableStatusCode(Int)

    /// Indicates `AnyObject` that represents the response is unexpected.
    case unexpectedObject(AnyObject)
}
