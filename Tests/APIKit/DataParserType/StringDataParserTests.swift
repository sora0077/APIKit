import XCTest
import Foundation
import APIKit

class StringDataParserTests: XCTestCase {
    func testAcceptHeader() {
        let parser = StringDataParser(encoding: String.Encoding.utf8)
        XCTAssertNil(parser.contentType)
    }
    
    func testParseData() {
        let string = "abcdef"
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let parser = StringDataParser(encoding: String.Encoding.utf8)

        do {
            let object = try parser.parseData(data)
            XCTAssertEqual(object as? String, string)
        } catch {
            XCTFail()
        }
    }

    func testInvalidString() {
        let bytes = [UInt8]([0xed, 0xa0, 0x80]) // U+D800 (high surrogate)
        let data = Data(bytes: bytes)
        let parser = StringDataParser(encoding: String.Encoding.utf8)

        do {
            _ = try parser.parseData(data)
            XCTFail()
        } catch {
            guard let error = error as? StringDataParser.Error,
                  case .invalidData(let invalidData) = error else {
                XCTFail()
                return
            }

            XCTAssertEqual(data, invalidData)
        }
    }
}
