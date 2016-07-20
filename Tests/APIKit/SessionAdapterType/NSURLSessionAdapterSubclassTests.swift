import Foundation
import XCTest
import OHHTTPStubs
import APIKit

class NSURLSessionAdapterSubclassTests: XCTestCase {
    class SessionAdapter: NSURLSessionAdapter {
        var functionCallFlags = [String: Bool]()

        override func urlSession(_ session: Foundation.URLSession, task: URLSessionTask, didCompleteWithError connectionError: NSError?) {
            functionCallFlags[(#function)] = true
            super.urlSession(session, task: task, didCompleteWithError: connectionError)
        }

        override func urlSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            functionCallFlags[(#function)] = true
            super.urlSession(session, dataTask: dataTask, didReceive: data)
        }
    }

    var adapter: SessionAdapter!
    var session: Session!

    override func setUp() {
        super.setUp()

        let configuration = URLSessionConfiguration.default
        adapter = SessionAdapter(configuration: configuration)
        session = Session(adapter: adapter)
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testDelegateMethodCall() {
        let data = try! JSONSerialization.data(withJSONObject: [:], options: [])
        
        OHHTTPStubs.stubRequests(passingTest: { request in
            return true
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)
        })
        
        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()
        
        session.sendRequest(request) { result in
            if case .failure = result {
                XCTFail()
            }

            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)

        XCTAssertEqual(adapter.functionCallFlags["urlSession(_:task:didCompleteWithError:)"], true)
        XCTAssertEqual(adapter.functionCallFlags["urlSession(_:dataTask:didReceive:)"], true)
    }
}
