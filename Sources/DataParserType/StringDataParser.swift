import Foundation

/// `StringDataParser` parses data and convert it to string.
public class StringDataParser: DataParserType {
    public enum Error: ErrorProtocol {
        case invalidData(Data)
    }

    /// The string encoding of the data.
    public let encoding: String.Encoding

    /// Returns `FormURLEncodedDataParser` with the string encoding.
    public init(encoding: String.Encoding = String.Encoding.utf8) {
        self.encoding = encoding
    }

    // MARK: - DataParserType

    /// Value for `Accept` header field of HTTP request.
    public var contentType: String? {
        return nil
    }

    /// Return `String` that converted from `Data`.
    /// - Throws: `StringDataParser.Error` when the parser fails to initialize `String` from `Data`.
    public func parseData(_ data: Data) throws -> AnyObject {
        guard let string = String(data: data, encoding: encoding) else {
            throw Error.invalidData(data)
        }

        return string
    }
}
