import Foundation

enum InputStreamError: ErrorProtocol {
    case invalidDataCapacity(Int)
    case unreadableStream(InputStream)
}

extension Data {
    init(inputStream: InputStream, capacity: Int = Int(UInt16.max)) throws {
        guard var data = Data(capacity: capacity) else {
            throw InputStreamError.invalidDataCapacity(capacity)
        }
        let bufferSize = Swift.min(Int(UInt16.max), capacity)
        let buffer = UnsafeMutablePointer<UInt8>(allocatingCapacity: bufferSize)

        var readSize: Int

        repeat {
            readSize = inputStream.read(buffer, maxLength: bufferSize)

            switch readSize {
            case let x where x > 0:
                data.append(buffer, count: readSize)

            case let x where x < 0:
                throw InputStreamError.unreadableStream(inputStream)

            default:
                break
            }
        } while readSize > 0

        buffer.deallocateCapacity(bufferSize)

        self.init(reference: data)
    }
}
