import Foundation

/// `SessionTaskError` represents an error that occurs while task for a request.
public enum SessionTaskError: ErrorProtocol {
    /// Error of `URLSession`.
    case connectionError(ErrorProtocol)

    /// Error while creating `URLReqeust` from `Request`.
    case requestError(ErrorProtocol)

    /// Error while creating `RequestType.Response` from `(Data, URLResponse)`.
    case responseError(ErrorProtocol)
}
