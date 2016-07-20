import Foundation
import APIKit
import XCTest
import OHHTTPStubs

class SessionCallbackQueueTests: XCTestCase {
    var adapter: TestSessionAdapter!
    var session: Session!

    override func setUp() {
        super.setUp()

        adapter = TestSessionAdapter()
        adapter.data = try! JSONSerialization.data(withJSONObject: ["key": "value"], options: [])

        session = Session(adapter: adapter, callbackQueue: .main)
    }

    func testMain() {
        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()

        session.sendRequest(request, callbackQueue: .main) { result in
            XCTAssert(Thread.isMainThread)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testSessionQueue() {
        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()

        session.sendRequest(request, callbackQueue: .sessionQueue) { result in
            // This depends on implementation of TestSessionAdapter
            XCTAssert(Thread.isMainThread)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testOperationQueue() {
        let operationQueue = OperationQueue()
        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()

        session.sendRequest(request, callbackQueue: .operationQueue(operationQueue)) { result in
            XCTAssertEqual(OperationQueue.current, operationQueue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testDispatchQueue() {
        let dispatchQueue = DispatchQueue.global(attributes: .qosDefault)
        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()

        session.sendRequest(request, callbackQueue: .dispatchQueue(dispatchQueue)) { result in
            // There is no way to test current dispatch queue.
            XCTAssert(!Thread.isMainThread)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    // MARK: Test Session.callbackQueue
    func testImplicitSessionCallbackQueue() {
        let operationQueue = OperationQueue()
        let session = Session(adapter: adapter, callbackQueue: .operationQueue(operationQueue))

        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()

        session.sendRequest(request) { result in
            XCTAssertEqual(OperationQueue.current, operationQueue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testExplicitSessionCallbackQueue() {
        let operationQueue = OperationQueue()
        let session = Session(adapter: adapter, callbackQueue: .operationQueue(operationQueue))

        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()

        session.sendRequest(request, callbackQueue: nil) { result in
            XCTAssertEqual(OperationQueue.current, operationQueue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
