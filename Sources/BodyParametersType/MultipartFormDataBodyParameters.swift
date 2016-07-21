import Foundation

#if os(iOS) || os(watchOS) || os(tvOS)
    import MobileCoreServices
#elseif os(OSX)
    import CoreServices
#endif

/// `FormURLEncodedBodyParameters` serializes array of `Part` for HTTP body and states its content type is multipart/form-data.
public struct MultipartFormDataBodyParameters: BodyParametersType {
    /// `EntityType` represents wheather the entity is expressed as `Data` or `InputStream`.
    public enum EntityType {
        /// Expresses the entity as `Data`, which has faster upload speed and lager memory usage.
        case data

        /// Expresses the entity as `InputStream`, which has smaller memory usage and slower upload speed.
        case inputStream
    }

    public let parts: [Part]
    public let boundary: String
    public let entityType: EntityType

    public init(parts: [Part], boundary: String = String(format: "%08x%08x", arc4random(), arc4random()), entityType: EntityType = .data) {
        self.parts = parts
        self.boundary = boundary
        self.entityType = entityType
    }

    // MARK: BodyParametersType

    /// `Content-Type` to send. The value for this property will be set to `Accept` HTTP header field.
    public var contentType: String {
        return "multipart/form-data; boundary=\(boundary)"
    }

    /// Builds `RequestBodyEntity.Data` that represents `form`.
    public func buildEntity() throws -> RequestBodyEntity {
        let inputStream = MultipartInputStream(parts: parts, boundary: boundary)

        switch entityType {
        case .inputStream:
            return .inputStream(inputStream)

        case .data:
            return .data(try Data(inputStream: inputStream))
        }
    }
}

public extension MultipartFormDataBodyParameters {
    /// Part represents single part of multipart/form-data.
    public struct Part {
        public enum Error: ErrorProtocol {
            case illegalValue(Any)
            case illegalFileURL(URL)
            case cannotGetFileSize(URL)
        }

        public let inputStream: InputStream
        public let name: String
        public let mimeType: String?
        public let fileName: String?
        public let length: Int

        /// Returns Part instance that has data presentation of passed value.
        /// `value` will be converted via `String(_:)` and serialized via `String.dataUsingEncoding(_:)`.
        /// If `mimeType` or `fileName` are `nil`, the fields will be omitted.
        public init(value: Any, name: String, mimeType: String? = nil, fileName: String? = nil, encoding: String.Encoding = String.Encoding.utf8) throws {
            guard let data = String(value).data(using: encoding) else {
                throw Error.illegalValue(value)
            }

            self.inputStream = InputStream(data: data)
            self.name = name
            self.mimeType = mimeType
            self.fileName = fileName
            self.length = data.count
        }

        /// Returns Part instance that has input stream of specifed data.
        /// If `mimeType` or `fileName` are `nil`, the fields will be omitted.
        public init(data: Data, name: String, mimeType: String? = nil, fileName: String? = nil) {
            self.inputStream = InputStream(data: data)
            self.name = name
            self.mimeType = mimeType
            self.fileName = fileName
            self.length = data.count
        }

        /// Returns Part instance that has input stream of specifed file URL.
        /// If `mimeType` or `fileName` are `nil`, values for the fields will be detected from URL.
        public init(fileURL: URL, name: String, mimeType: String? = nil, fileName: String? = nil) throws {
            guard let inputStream = InputStream(url: fileURL) else {
                throw Error.illegalFileURL(fileURL)
            }

            let fileSize = fileURL.path
                .flatMap { try? FileManager.default.attributesOfItem(atPath: $0) }
                .flatMap { $0[FileAttributeKey.size] as? NSNumber }
                .map { $0.intValue }

            guard let bodyLength = fileSize else {
                throw Error.cannotGetFileSize(fileURL)
            }

            let detectedMimeType = fileURL.pathExtension
                .flatMap { UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, $0, nil)?.takeRetainedValue() }
                .flatMap { UTTypeCopyPreferredTagWithClass($0, kUTTagClassMIMEType)?.takeRetainedValue() }
                .map { $0 as String }

            self.inputStream = inputStream
            self.name = name
            self.mimeType = mimeType ?? detectedMimeType ?? "application/octet-stream"
            self.fileName = fileName ?? fileURL.lastPathComponent
            self.length = bodyLength
        }
    }

    internal class PartInputStream: AbstractInputStream {
        let headerData: Data
        let footerData: Data
        let bodyPart: Part

        let totalLength: Int
        var totalSentLength: Int

        init(part: Part, boundary: String) {
            let header: String
            switch (part.mimeType, part.fileName) {
            case (let mimeType?, let fileName?):
                header = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(part.name)\"; filename=\"\(fileName)\"\r\nContent-Type: \(mimeType)\r\n\r\n"

            case (let mimeType?, _):
                header = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(part.name)\"; \r\nContent-Type: \(mimeType)\r\n\r\n"

            default:
                header = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(part.name)\"\r\n\r\n"
            }

            headerData = header.data(using: String.Encoding.utf8)!
            footerData = "\r\n".data(using: String.Encoding.utf8)!
            bodyPart = part
            totalLength = headerData.count + bodyPart.length + footerData.count
            totalSentLength = 0

            super.init()
        }

        var headerRange: CountableRange<Int> {
            return 0..<headerData.count
        }

        var bodyRange: CountableRange<Int> {
            return headerRange.endIndex..<(headerRange.endIndex + bodyPart.length)
        }

        var footerRange: CountableRange<Int> {
            return bodyRange.endIndex..<(bodyRange.endIndex + footerData.count)
        }

        // MARK: InputStream
        override var hasBytesAvailable: Bool {
            return totalSentLength < totalLength
        }

        override func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength: Int) -> Int {
            var sentLength = 0

            while sentLength < maxLength && totalSentLength < totalLength {
                let offsetBuffer = buffer + sentLength
                let availableLength = maxLength - sentLength

                switch totalSentLength {
                case headerRange:
                    let readLength = min(headerRange.endIndex - totalSentLength, availableLength)
                    let readRange = NSRange(location: totalSentLength - headerRange.startIndex, length: readLength)
                    (headerData as NSData).getBytes(offsetBuffer, range: readRange)
                    sentLength += readLength
                    totalSentLength += sentLength

                case bodyRange:
                    if bodyPart.inputStream.streamStatus == .notOpen {
                        bodyPart.inputStream.open()
                    }

                    let readLength = bodyPart.inputStream.read(offsetBuffer, maxLength: availableLength)
                    sentLength += readLength
                    totalSentLength += readLength

                case footerRange:
                    let readLength = min(footerRange.endIndex - totalSentLength, availableLength)
                    let range = NSRange(location: totalSentLength - footerRange.startIndex, length: readLength)
                    (footerData as NSData).getBytes(offsetBuffer, range: range)
                    sentLength += readLength
                    totalSentLength += readLength

                default:
                    print("Illegal range access: \(totalSentLength) is out of \(headerRange.startIndex)..<\(footerRange.endIndex)")
                    return -1
                }
            }

            return sentLength;
        }
    }

    internal class MultipartInputStream: AbstractInputStream {
        let boundary: String
        let partStreams: [PartInputStream]
        let footerData: Data

        let totalLength: Int
        var totalSentLength: Int

        private var privateStreamStatus = Stream.Status.notOpen

        init(parts: [Part], boundary: String) {
            self.boundary = boundary
            self.partStreams = parts.map { PartInputStream(part: $0, boundary: boundary) }
            self.footerData = "--\(boundary)--\r\n".data(using: String.Encoding.utf8)!
            self.totalLength = partStreams.reduce(footerData.count) { $0 + $1.totalLength }
            self.totalSentLength = 0
            super.init()
        }

        var partsRange: CountableRange<Int> {
            return 0..<partStreams.reduce(0) { $0 + $1.totalLength }
        }

        var footerRange: CountableRange<Int> {
            return partsRange.endIndex..<(partsRange.endIndex + footerData.count)
        }

        var currentPartInputStream: PartInputStream? {
            var currentOffset = 0

            for partStream in partStreams {
                let partStreamRange = currentOffset..<(currentOffset + partStream.totalLength)
                if partStreamRange.contains(totalSentLength) {
                    return partStream
                }

                currentOffset += partStream.totalLength
            }

            return nil
        }

        // MARK: InputStream
        // NOTE: InputStream does not have its own implementation because it is a class cluster.
        override var streamStatus: Stream.Status {
            return privateStreamStatus
        }

        override var hasBytesAvailable: Bool {
            return totalSentLength < totalLength
        }

        override func open() {
            privateStreamStatus = .open
        }

        override func close() {
            privateStreamStatus = .closed
        }

        override func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength: Int) -> Int {
            privateStreamStatus = .reading

            var sentLength = 0

            while sentLength < maxLength && totalSentLength < totalLength {
                let offsetBuffer = buffer + sentLength
                let availableLength = maxLength - sentLength

                switch totalSentLength {
                case partsRange:
                    guard let partStream = currentPartInputStream else {
                        print("Illegal offset \(totalLength) for part streams \(partsRange)")
                        return -1
                    }

                    let readLength = partStream.read(offsetBuffer, maxLength: availableLength)
                    sentLength += readLength
                    totalSentLength += readLength

                case footerRange:
                    let readLength = min(footerRange.endIndex - totalSentLength, availableLength)
                    let range = NSRange(location: totalSentLength - footerRange.startIndex, length: readLength)
                    (footerData as NSData).getBytes(offsetBuffer, range: range)
                    sentLength += readLength
                    totalSentLength += readLength

                default:
                    print("Illegal range access: \(totalSentLength) is out of \(partsRange.startIndex)..<\(footerRange.endIndex)")
                    return -1
                }

                if privateStreamStatus != .closed && !hasBytesAvailable {
                    privateStreamStatus = .atEnd
                }
            }

            return sentLength
        }

        override var delegate: StreamDelegate? {
            get { return nil }
            set { }
        }

        override func schedule(in runLoop: RunLoop, forMode mode: RunLoopMode) {

        }

        override func remove(from runLoop: RunLoop, forMode mode: RunLoopMode) {

        }
    }
}
