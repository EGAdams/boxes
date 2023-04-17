import Foundation

protocol DownloadCallbackManagerDelegate: AnyObject {
    func downloadCallbackManager(_ downloadCallbackManager: DownloadCallbackManager, didFinishDownloading identifier: String)
}

class DownloadCallbackManager: NSObject, URLSessionDownloadDelegate, DownloaderDelegate {

    // Add the delegate property
    weak var delegate: DownloadCallbackManagerDelegate?
     
    private var callbackQueue: [String: DownloadCallbackManagerDelegate] = [:]
    private let queue = DispatchQueue(label: "com.downloadcallbackmanager.queue")

    func addDownloadFinishedCallback(delegate: DownloadCallbackManagerDelegate, identifier: String) {
        queue.sync {
            callbackQueue[identifier] = delegate
        }}

    func removeDownloadFinishedCallback(identifier: String) {
        queue.sync {
            callbackQueue.removeValue(forKey: identifier)
            return // rid warning
        }
    }

    func callDownloadFinishedCallback(identifier: String, location: URL?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let delegate = self.callbackQueue[identifier] {
                delegate.downloadCallbackManager(self, didFinishDownloading: identifier)
            }
        }}
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            // Get the identifier
            guard let identifier = downloadTask.taskDescription else { return }

            // Call the delegate method
            self.delegate?.downloadCallbackManager(self, didFinishDownloading: identifier)}

    // DownloaderDelegate methods
    func downloader(_ downloader: Downloader, didFinishDownloadingTo location: URL, for identifier: String) {
        // Handle download completion
    }
    
    func downloader(_ downloader: Downloader, didFailWithError error: Error, for identifier: String) {
        // Handle download failure
    }
}
