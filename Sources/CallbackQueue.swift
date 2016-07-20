import Foundation

/// `CallbackQueue` represents queue where `handler` of `Session.sendRequest(_:handler:)` runs.
public enum CallbackQueue {
    /// Dispatches callback closure on main queue asynchronously.
    case main

    /// Dispatches callback closure on the queue where backend adapter callback runs.
    case sessionQueue

    /// Dispatches callback closure on associated operation queue.
    case operationQueue(Foundation.OperationQueue)

    /// Dispatches callback closure on associated dispatch queue.
    case dispatchQueue(Dispatch.DispatchQueue)

    internal func execute(_ closure: () -> Void) {
        switch self {
        case .main:
            DispatchQueue.main.async {
                closure()
            }

        case .sessionQueue:
            closure()

        case .operationQueue(let operationQueue):
            operationQueue.addOperation {
                closure()
            }

        case .dispatchQueue(let dispatchQueue):
            dispatchQueue.async {
                closure()
            }
        }
    }
}
