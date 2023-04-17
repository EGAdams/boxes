import UIKit
import WebKit

/** @class ViewController */
class ViewController: UIViewController, JavaScriptInterfaceDelegate, DownloaderDelegate, DownloadCallbackManagerDelegate {
    var webView: WKWebView!
    private var javascriptBridge: WKUserContentController!
    private var javascriptInterface: JavaScriptInterface!
    private var loggingNavigationDelegate: LoggingNavigationDelegate!
    
    // Initialize the required classes
    private let downloader = Downloader(delegate: self)
    private let downloadCallbackManager = DownloadCallbackManager()
    private let completionHandlerManager = CompletionHandlerManager()
    private let downloadProgressTracker = DownloadProgressTracker()
    private let fileHandler = FileHandler()
    
    // private let downloader = Downloader(delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the downloader
        downloader.delegate = downloadCallbackManager
        downloadCallbackManager.delegate = self
        
        // Start downloading the required files
        let remoteBaseURL = URL(string: "http://americansjewelry.com/chat/")!
        let filesToDownload = ["chat.html", "config.json", "css/chat.css", "js/chat.js"]
        for file in filesToDownload {
            let remoteURL = remoteBaseURL.appendingPathComponent(file)
            let localURL = fileHandler.localFileURL(for: remoteURL, in: "chat") ?? URL(fileURLWithPath: "")
            completionHandlerManager.addCompletionHandler({ [weak self] location, response, error in
                guard let self = self, let location = location else { return }
                do {
                    try self.fileHandler.saveFile(from: location, to: localURL)
                    self.downloadProgressTracker.allFilesDownloaded()
                } catch {
                    print("Error saving file: \(error.localizedDescription)")
                }
            }, forIdentifier: file)
            downloader.downloadFile(from: remoteURL, identifier: file)
        }
        
        // Configure the WebView
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webConfiguration.userContentController = WKUserContentController()
        webView = WKWebView(frame: view.frame, configuration: webConfiguration)
        
        // Set up the JavaScript interface and logging navigation delegate
        javascriptInterface = JavaScriptInterface(webView: webView)
        javascriptInterface.delegate = self
        webConfiguration.userContentController.add(javascriptInterface, name: "MyApp")
        loggingNavigationDelegate = LoggingNavigationDelegate()
        webView.navigationDelegate = loggingNavigationDelegate
        view.addSubview(webView)
    }
    
    func javascriptInterface(_ javascriptInterface: JavaScriptInterface, didReceiveMessage message: WKScriptMessage) {
        print("Received message from JavaScript: \(message.body)")
    }
    
    // MARK: - DownloadCallbackManagerDelegate
    func downloadCallbackManager(_ downloadCallbackManager: DownloadCallbackManager, didFinishDownloading identifier: String) {
        if downloadProgressTracker.allFilesDownloaded() {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let localURL = self.fileHandler.localFileURL(for: URL(string: "chat.html")!, in: "chat") {
                    let urlRequest = URLRequest(url: localURL)
                    self.webView.load(urlRequest)
                }
            }
        }
    }
    
    func downloadFiles() {
        let remoteURLs = [
            "http://americansjewelry.com/chat/chat.html",
            "http://americansjewelry.com/chat/config.json",
            "http://americansjewelry.com/chat/css/chat.css",
            "http://americansjewelry.com/chat/js/chat.js"
        ]
        
        for urlString in remoteURLs {
            if let url = URL(string: urlString) {
                downloader.downloadFile(with: url, identifier: url.lastPathComponent)
            }
        }
    }
    
    // DownloaderDelegate methods
    func downloader(_ downloader: Downloader, didFinishDownloadingTo location: URL, for identifier: String) {
        // Implement the method for handling successful download
    }

    func downloader(_ downloader: Downloader, didFailWithError error: Error, for identifier: String) {
        // Implement the method for handling download failure
    }
    
    
}
