//
//  DownloadCallbackManager.swift
//
//  Created by Clay Ackerland on 4/16/23.
//
import Foundation

protocol DownloadCallbackManagerDelegate: AnyObject {
    func downloadCallbackManager(_ downloadCallbackManager: DownloadCallbackManager, didFinishDownloading identifier: String)
}

class DownloadCallbackManager: NSObject, URLSessionDownloadDelegate {

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
        }}

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
}
