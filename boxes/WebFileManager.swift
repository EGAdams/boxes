//
//  WebFileManager.swift
//  boxes
//
//  Created by Clay Ackerland on 4/17/23.
//
import Foundation

class WebFileManager: DownloaderDelegate {
    private var downloader: Downloader?
    private let fileHandler: FileHandler
    private let downloadProgressTracker: DownloadProgressTracker
    private let downloadCallbackManager: DownloadCallbackManager
    private let completionHandlerManager: CompletionHandlerManager
    
    init() {
        self.fileHandler = FileHandler()
        self.downloadCallbackManager = DownloadCallbackManager()
        downloadProgressTracker = DownloadProgressTracker()
        completionHandlerManager = CompletionHandlerManager()
        self.downloader = Downloader(delegate: self)
        
        if let downloader = downloader {
            downloader.delegate = downloadCallbackManager
        }

        downloadCallbackManager.delegate = self
    }
    
    func downloadFiles(files: [URL: String], completion: @escaping () -> Void) {
        print("Starting file downloads...") // Add this print statement
        
        let dispatchGroup = DispatchGroup()
        for (url, identifier) in files {
            dispatchGroup.enter()
            downloadFile(from: url, withIdentifier: identifier) { success in
                print("Downloaded \(url) with identifier: \(identifier), success: \(success)") // Add this print statement
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    private func downloadFile(from url: URL, withIdentifier identifier: String, completion: @escaping (Bool) -> Void) {
        let downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] (location, response, error) in
            guard let self = self, let location = location else {
                completion(false)
                return
            }
            
            let localURL = self.getLocalFileURL(for: url)
            let fileManager = FileManager.default
            
            do {
                if fileManager.fileExists(atPath: localURL.path) {
                    try fileManager.removeItem(at: localURL)
                }
                
                try fileManager.copyItem(at: location, to: localURL)
                completion(true)
            } catch {
                print("Error while copying file: \(error)")
                completion(false)
            }
        }
        
        downloadTask.resume()
    }
    
    private func getLocalFileURL(for remoteURL: URL) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(remoteURL.lastPathComponent)
        return fileURL
    }

    func prepareWebView() -> URL? {
        print("Preparing WebView...")
        guard let chatHTMLFileURL = URL(string: "https://americansjewelry.com/chat/chat.html") else { return nil }
        return getLocalFileURL(for: chatHTMLFileURL)
    }



    func downloader(_ downloader: Downloader, didFinishDownloadingTo location: URL, for identifier: String) {
        // Handle the download completion
    }

    func downloader(_ downloader: Downloader, didFailWithError error: Error, for identifier: String) {
        // Handle the download failure
    }
}

extension WebFileManager: DownloadCallbackManagerDelegate {
    func downloadCallbackManager(_ downloadCallbackManager: DownloadCallbackManager, didFinishDownloading identifier: String) {
        // Handle download completion
    }
}
