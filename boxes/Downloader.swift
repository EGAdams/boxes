//
//  Downloader.swift
//
//  Created by Clay Ackerland on 4/16/23.
//
import Foundation

protocol DownloaderDelegate: AnyObject {
    func downloader(_ downloader: Downloader, didFinishDownloadingTo location: URL, for identifier: String)
    func downloader(_ downloader: Downloader, didFailWithError error: Error, for identifier: String)
}

class Downloader: NSObject {
    private var urlSession: URLSession!
    private let sessionConfiguration: URLSessionConfiguration
    private var downloadTasks: [String: URLSessionDownloadTask]
    weak var delegate: DownloaderDelegate?
    
    init(delegate: DownloaderDelegate?, sessionConfiguration: URLSessionConfiguration = .default) {
        self.delegate = delegate
        self.sessionConfiguration = sessionConfiguration
        self.downloadTasks = [:]
        super.init()
        self.urlSession = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
    }

    func downloadFile(with url: URL, identifier: String) {
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTasks[identifier] = downloadTask
        downloadTask.resume()
    }

    func cancelDownload(for identifier: String) {
        if let downloadTask = downloadTasks[identifier] {
            downloadTask.cancel()
            downloadTasks.removeValue(forKey: identifier)
        }
    }
}

extension Downloader: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let identifier = downloadTasks.first(where: { $0.value == downloadTask })?.key else { return }
        delegate?.downloader(self, didFinishDownloadingTo: location, for: identifier)
        downloadTasks.removeValue(forKey: identifier)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let identifier = downloadTasks.first(where: { $0.value == task })?.key else { return }
        if let error = error {
            delegate?.downloader(self, didFailWithError: error, for: identifier)
        }
        downloadTasks.removeValue(forKey: identifier)
    }
}

extension Downloader: URLSessionTaskDelegate {
    // Additional task delegate methods can be implemented here if needed.
}
