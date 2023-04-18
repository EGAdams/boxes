import UIKit
import WebKit

/** @class ViewController */
class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    var webView: WKWebView!
    private var javascriptBridge: WKUserContentController!
    private var javascriptInterface: JavaScriptInterface!
    private var loggingNavigationDelegate: LoggingNavigationDelegate!
    
    private let webFileManager = WebFileManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print( "entering view did load in the view controller... " )
        let filesToDownload: [URL: String] = [
            URL(string: "https://americansjewelry.com/chat/chat.html")!: "chatHTML",
            URL(string: "https://americansjewelry.com/chat/config.json")!: "configJSON",
            URL(string: "https://americansjewelry.com/chat/js/chat.js")!: "chatJS",
            URL(string: "https://americansjewelry.com/chat/css/chat.css")!: "chatCSS"
        ]
        
        print("Files to download: \(filesToDownload)")
        
        // Delete local files before downloading new ones
        webFileManager.deleteLocalFiles(files: filesToDownload)

        webFileManager.downloadFiles(files: filesToDownload) { [weak self] in
            guard let self = self else { return }
            if let fileURL = self.webFileManager.prepareWebView() {
                print("WebView base URL: \(fileURL.deletingLastPathComponent())") // Add this print statement
                self.setupWebView()
                print("File URL: \(fileURL)")
                self.webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
            }
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "jsLog" {
            print("JavaScript Log: \(message.body)")
        }
    }
    
    // Implement the required method of the JavaScriptInterfaceDelegate protocol
    func javascriptInterface( _ javascriptInterface: JavaScriptInterface, didReceiveMessage message: WKScriptMessage ) {
        // Example: print the message body
        print( "Received message from JavaScript: \( message.body )" )
    }

    func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        let contentController = webView.configuration.userContentController
        let script = """
            function logToNative(message) {
                window.webkit.messageHandlers.jsLog.postMessage(message);
            }
            console.log = function(message) {
                logToNative(message);
            }
        """
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        contentController.addUserScript(userScript)
        
        let javaScriptLogger = JavaScriptLogger()
        contentController.add(javaScriptLogger, name: "jsLog")
    }

}


