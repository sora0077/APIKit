import Foundation
import XCTest
import APIKit

class URLEncodedSerializationTests: XCTestCase {
    // MARK: Data -> AnyObject
    func testObjectFromData() {
        let data = "key1=value1&key2=value2".data(using: String.Encoding.utf8)!
        let object = try? URLEncodedSerialization.objectFromData(data, encoding: String.Encoding.utf8)
        XCTAssertEqual(object?["key1"], "value1")
        XCTAssertEqual(object?["key2"], "value2")
    }

    func testInvalidFormatString() {
        let string = "key==value&"

        do {
            let data = string.data(using: String.Encoding.utf8)!
            _ = try URLEncodedSerialization.objectFromData(data, encoding: String.Encoding.utf8)
            XCTFail()
        } catch {
            guard let error = error as? URLEncodedSerialization.Error,
                  case .invalidFormatString(let invalidString) = error else {
                XCTFail()
                return
            }

            XCTAssertEqual(string, invalidString)
        }
    }

    func testInvalidString() {
        let bytes = [UInt8]([0xed, 0xa0, 0x80]) // U+D800 (high surrogate)
        let data = Data(bytes: bytes)

        do {
            _ = try URLEncodedSerialization.objectFromData(data, encoding: String.Encoding.utf8)
            XCTFail()
        } catch {
            guard let error = error as? URLEncodedSerialization.Error,
                  case .cannotGetStringFromData(let invalidData, let encoding) = error else {
                XCTFail()
                return
            }

            XCTAssertEqual(data, invalidData)
            XCTAssertEqual(encoding, String.Encoding.utf8)
        }
    }

    // MARK: AnyObject -> Data
    func testDataFromObject() {
        let object = ["hey": "yo"] as AnyObject
        let data = try? URLEncodedSerialization.dataFromObject(object, encoding: String.Encoding.utf8)
        let string = data.flatMap { String(data: $0, encoding: String.Encoding.utf8) }
        XCTAssertEqual(string, "hey=yo")
    }

    func testNonDictionaryObject() {
        let dictionaries = [["hey": "yo"]] as AnyObject

        do {
            _ = try URLEncodedSerialization.dataFromObject(dictionaries, encoding: String.Encoding.utf8)
            XCTFail()
        } catch {
            guard let error = error as? URLEncodedSerialization.Error,
                  case .cannotCastObjectToDictionary(let object) = error else {
                XCTFail()
                return
            }

            XCTAssertEqual(object["hey"], dictionaries["hey"])
        }
    }
}
