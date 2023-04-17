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
            print("Finished downloading files")
        }
    }
    
    private func downloadFile(from url: URL, withIdentifier identifier: String, completion: @escaping (Bool) -> Void) {
        let localURL = getLocalFileURL(for: url)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading \(url): \(error)")
                completion(false)
                return
            }

            guard let data = data else {
                print("No data received for \(url)")
                completion(false)
                return
            }

            do {
                try data.write(to: localURL)
                print("\(identifier) downloaded and saved to \(localURL)")

                // Add these lines to print the content of the downloaded files
                do {
                    let fileContent = try String(contentsOf: localURL)
                    print("File content for \(identifier):")
                    print(fileContent)
                } catch {
                    print("Error reading file content for \(identifier): \(error)")
                }

                completion(true)
            } catch {
                print("Error writing data to \(localURL): \(error)")
                completion(false)
            }
        }
        task.resume()
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
