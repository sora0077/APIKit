import Foundation

/// `SessionTaskError` represents an error that occurs while task for a request.
public enum SessionTaskError: ErrorProtocol {
    /// Error of `NSURLSession`.
    case connectionError(ErrorProtocol)

    /// Error while creating `NSURLReqeust` from `Request`.
    case requestError(ErrorProtocol)

    /// Error while creating `RequestType.Response` from `(NSData, NSURLResponse)`.
    case responseError(ErrorProtocol)
}
