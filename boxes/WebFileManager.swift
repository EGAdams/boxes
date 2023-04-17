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
    
    func downloadFiles( files: [URL: String], completion: @escaping () -> Void ) {
        // Download files
    }
    
    func prepareWebView() -> URL? {
        print("Preparing WebView...")
        guard let chatHTMLFileURL = URL(string: "http://americansjewelry.com/chat/chat.html") else { return nil }
        return getLocalURL(for: chatHTMLFileURL)
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
