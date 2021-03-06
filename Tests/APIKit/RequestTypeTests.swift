import XCTest
import APIKit

class RequestTypeTests: XCTestCase {
    func testJapanesesQueryParameters() {
        let request = TestRequest(parameters: ["q": "こんにちは"])
        let URLRequest = try? request.buildURLRequest()
        XCTAssertEqual(URLRequest?.url?.query, "q=%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AF")
    }
    
    func testSymbolQueryParameters() {
        let request = TestRequest(parameters: ["q": "!\"#$%&'()0=~|`{}*+<>?/_"])
        let URLRequest = try? request.buildURLRequest()
        XCTAssertEqual(URLRequest?.url?.query, "q=%21%22%23%24%25%26%27%28%290%3D~%7C%60%7B%7D%2A%2B%3C%3E?/_")
    }

    func testNullQueryParameters() {
        let request = TestRequest(parameters: ["null": NSNull()])
        let URLRequest = try? request.buildURLRequest()
        XCTAssertEqual(URLRequest?.url?.query, "null")
    }
    
    func testheaderFields() {
        let request = TestRequest(headerFields: ["Foo": "f", "Accept": "a", "Content-Type": "c"])
        let URLReqeust = try? request.buildURLRequest()
        XCTAssertEqual(URLReqeust?.value(forHTTPHeaderField: "Foo"), "f")
        XCTAssertEqual(URLReqeust?.value(forHTTPHeaderField: "Accept"), "a")
        XCTAssertEqual(URLReqeust?.value(forHTTPHeaderField: "Content-Type"), "c")
    }

    func testPOSTJSONRequest() {
        let parameters: [AnyObject] = [
            ["id": "1"],
            ["id": "2"],
            ["hello", "yellow"]
        ]

        let request = TestRequest(method: .POST, parameters: parameters)
        XCTAssert(request.parameters?.count == 3)

        let URLRequest = try? request.buildURLRequest()
        XCTAssertNotNil(URLRequest?.httpBody)

        let json = URLRequest?.httpBody.flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) } as? [AnyObject]
        XCTAssertEqual(json?.count, 3)
        XCTAssertEqual(json?[0]["id"], "1")
        XCTAssertEqual(json?[1]["id"], "2")

        let array = json?[2] as? [String]
        XCTAssertEqual(array?[0], "hello")
        XCTAssertEqual(array?[1], "yellow")
    }

    func testPOSTInvalidJSONRequest() {
        let request = TestRequest(method: .POST, parameters: "foo")
        let URLRequest = try? request.buildURLRequest()
        XCTAssertNil(URLRequest?.httpBody)
    }

    func testBuildURL() {
        // MARK: - baseURL = https://example.com
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com", path: "").absoluteURL,
            URL(string: "https://example.com")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com", path: "/").absoluteURL,
            URL(string: "https://example.com/")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com", path: "/", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com", path: "foo").absoluteURL,
            URL(string: "https://example.com/foo")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com", path: "/foo", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/foo?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com", path: "/foo/").absoluteURL,
            URL(string: "https://example.com/foo/")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com", path: "/foo/", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/foo/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com", path: "foo/bar").absoluteURL,
            URL(string: "https://example.com/foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com", path: "/foo/bar").absoluteURL,
            URL(string: "https://example.com/foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com", path: "/foo/bar", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/foo/bar?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com", path: "/foo/bar/").absoluteURL,
            URL(string: "https://example.com/foo/bar/")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com", path: "/foo/bar/", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com", path: "/foo/bar//").absoluteURL,
            URL(string: "https://example.com/foo/bar//")
        )
        
        // MARK: - baseURL = https://example.com/
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/", path: "").absoluteURL,
            URL(string: "https://example.com/")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/", path: "/").absoluteURL,
            URL(string: "https://example.com//")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/", path: "/", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com//?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/", path: "foo").absoluteURL,
            URL(string: "https://example.com/foo")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/", path: "/foo").absoluteURL,
            URL(string: "https://example.com//foo")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/", path: "/foo", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com//foo?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/", path: "/foo/").absoluteURL,
            URL(string: "https://example.com//foo/")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/", path: "/foo/", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com//foo/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/", path: "foo/bar").absoluteURL,
            URL(string: "https://example.com/foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/", path: "/foo/bar").absoluteURL,
            URL(string: "https://example.com//foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/", path: "/foo/bar", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com//foo/bar?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/", path: "/foo/bar/").absoluteURL,
            URL(string: "https://example.com//foo/bar/")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/", path: "/foo/bar/", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com//foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/", path: "foo//bar//").absoluteURL,
            URL(string: "https://example.com/foo//bar//")
        )
        
        // MARK: - baseURL = https://example.com/api
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api", path: "").absoluteURL,
            URL(string: "https://example.com/api")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api", path: "/").absoluteURL,
            URL(string: "https://example.com/api/")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api", path: "/", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api", path: "foo").absoluteURL,
            URL(string: "https://example.com/api/foo")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api", path: "/foo").absoluteURL,
            URL(string: "https://example.com/api/foo")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api", path: "/foo", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api/foo?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api", path: "/foo/").absoluteURL,
            URL(string: "https://example.com/api/foo/")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api", path: "/foo/", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api/foo/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api", path: "foo/bar").absoluteURL,
            URL(string: "https://example.com/api/foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api", path: "/foo/bar").absoluteURL,
            URL(string: "https://example.com/api/foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api", path: "/foo/bar", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api/foo/bar?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api", path: "/foo/bar/").absoluteURL,
            URL(string: "https://example.com/api/foo/bar/")
        )

        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api", path: "/foo/bar/", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api/foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api", path: "foo//bar//").absoluteURL,
            URL(string: "https://example.com/api/foo//bar//")
        )
        
        // MARK: - baseURL = https://example.com/api/
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api/", path: "").absoluteURL,
            URL(string: "https://example.com/api/")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api/", path: "/").absoluteURL,
            URL(string: "https://example.com/api//")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api/", path: "/", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api//?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api/", path: "foo").absoluteURL,
            URL(string: "https://example.com/api/foo")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api/", path: "/foo").absoluteURL,
            URL(string: "https://example.com/api//foo")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api/", path: "/foo", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api//foo?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api/", path: "/foo/").absoluteURL,
            URL(string: "https://example.com/api//foo/")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api/", path: "/foo/", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api//foo/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api/", path: "foo/bar").absoluteURL,
            URL(string: "https://example.com/api/foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api/", path: "/foo/bar").absoluteURL,
            URL(string: "https://example.com/api//foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api/", path: "/foo/bar", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api//foo/bar?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api/", path: "/foo/bar/").absoluteURL,
            URL(string: "https://example.com/api//foo/bar/")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api/", path: "/foo/bar/", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api//foo/bar/?p=1")
        )

        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com/api/", path: "foo//bar//").absoluteURL,
            URL(string: "https://example.com/api/foo//bar//")
        )
        
        //　MARK: - baseURL = https://example.com///
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com///", path: "").absoluteURL,
            URL(string: "https://example.com///")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com///", path: "/").absoluteURL,
            URL(string: "https://example.com////")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com///", path: "/", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com////?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com///", path: "foo").absoluteURL,
            URL(string: "https://example.com///foo")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com///", path: "/foo").absoluteURL,
            URL(string: "https://example.com////foo")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com///", path: "/foo", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com////foo?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com///", path: "/foo/").absoluteURL,
            URL(string: "https://example.com////foo/")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com///", path: "/foo/", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com////foo/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com///", path: "foo/bar").absoluteURL,
            URL(string: "https://example.com///foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com///", path: "/foo/bar").absoluteURL,
            URL(string: "https://example.com////foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com///", path: "/foo/bar", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com////foo/bar?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com///", path: "/foo/bar/").absoluteURL,
            URL(string: "https://example.com////foo/bar/")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com///", path: "/foo/bar/", parameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com////foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest(baseURL: "https://example.com///", path: "foo//bar//").absoluteURL,
            URL(string: "https://example.com///foo//bar//")
        )
    }

    func testInterceptURLRequest() {
        let URL = Foundation.URL(string: "https://example.com/customize")!
        let request = TestRequest() { _ in
            return URLRequest(url: URL)
        }

        XCTAssertEqual((try? request.buildURLRequest())?.url, URL)
    }
}
