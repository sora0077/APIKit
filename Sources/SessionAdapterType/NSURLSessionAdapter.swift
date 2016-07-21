import Foundation

extension URLSessionTask: SessionTaskType {

}

private var dataTaskResponseBufferKey = 0
private var taskAssociatedObjectCompletionHandlerKey = 0

/// `NSURLSessionAdapter` connects `URLSession` with `Session`.
///
/// If you want to add custom behavior of `URLSession` by implementing delegate methods defined in
/// `URLSessionDelegate` and related protocols, define a subclass of `NSURLSessionAdapter` and implment
/// delegate methods that you want to implement. Since `NSURLSessionAdapter` also implements delegate methods
/// `URLSession(_:task: didCompleteWithError:)` and `URLSession(_:dataTask:didReceiveData:)`, you have to call
/// `super` in these methods if you implement them.
public class NSURLSessionAdapter: NSObject, SessionAdapterType, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    /// The undelying `URLSession` instance.
    public var URLSession: Foundation.URLSession!

    /// Returns `NSURLSessionAdapter` initialized with `NSURLSessionConfiguration`.
    public init(configuration: URLSessionConfiguration) {
        super.init()
        self.URLSession = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    /// Creates `URLSessionDataTask` instance using `dataTaskWithRequest(_:completionHandler:)`.
    public func createTaskWithURLRequest(_ URLRequest: Foundation.URLRequest, handler: (Data?, URLResponse?, ErrorProtocol?) -> Void) -> SessionTaskType {
        let task = URLSession.dataTask(with: URLRequest)

        setBuffer(NSMutableData(), forTask: task)
        setHandler(handler, forTask: task)

        task.resume()

        return task
    }

    /// Aggregates `URLSessionTask` instances in `URLSession` using `getTasksWithCompletionHandler(_:)`.
    public func getTasksWithHandler(_ handler: ([SessionTaskType]) -> Void) {
        URLSession.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            let allTasks = dataTasks as [URLSessionTask]
                + uploadTasks as [URLSessionTask]
                + downloadTasks as [URLSessionTask]

            handler(allTasks.map { $0 })
        }
    }

    private func setBuffer(_ buffer: NSMutableData, forTask task: URLSessionTask) {
        objc_setAssociatedObject(task, &dataTaskResponseBufferKey, buffer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    private func bufferForTask(_ task: URLSessionTask) -> NSMutableData? {
        return objc_getAssociatedObject(task, &dataTaskResponseBufferKey) as? NSMutableData
    }

    private func setHandler(_ handler: (Data?, URLResponse?, NSError?) -> Void, forTask task: URLSessionTask) {
        objc_setAssociatedObject(task, &taskAssociatedObjectCompletionHandlerKey, Box(handler), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    private func handlerForTask(_ task: URLSessionTask) -> ((Data?, URLResponse?, NSError?) -> Void)? {
        return (objc_getAssociatedObject(task, &taskAssociatedObjectCompletionHandlerKey) as? Box<(Data?, URLResponse?, NSError?) -> Void>)?.value
    }

    // MARK: URLSessionTaskDelegate
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError connectionError: NSError?) {
        handlerForTask(task)?(bufferForTask(task).map(Data.init), task.response, connectionError)
    }

    // MARK: URLSessionDataDelegate
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        bufferForTask(dataTask)?.append(data)
    }
}
