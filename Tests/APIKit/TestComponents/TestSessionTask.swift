import Foundation
import APIKit

class TestSessionTask: SessionTaskType {
    
    var handler: (Data?, URLResponse?, ErrorProtocol?) -> Void
    var cancelled = false

    init(handler: (Data?, URLResponse?, ErrorProtocol?) -> Void) {
        self.handler = handler
    }

    func resume() {

    }

    func cancel() {
        cancelled = true
    }
}
