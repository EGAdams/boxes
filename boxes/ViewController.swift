import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    private var javascriptBridge: WKUserContentController!
    private var javascriptInterface: JavaScriptInterface!
    private var loggingNavigationDelegate: LoggingNavigationDelegate!
    private let webFileManager = WebFileManager()
    private var errorLoggingScriptMessageHandler: ErrorLoggingScriptMessageHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("entering view did load in the view controller... ")
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
        let filesToDownload: [URL: String] = [
            URL(string: "https://americansjewelry.com/chat/chat.html")!: "chatHTML",
            URL(string: "https://americansjewelry.com/chat/config.json")!: "configJSON",
            URL(string: "https://americansjewelry.com/chat/js/chat.js")!: "chatJS",
            URL(string: "https://americansjewelry.com/chat/css/chat.css")!: "chatCSS"
        ]

        setupWebView() // Move this line here

        webFileManager.deleteLocalFiles(files: filesToDownload)
        webFileManager.downloadFiles(files: filesToDownload) { [weak self] in
            guard let self = self else { return }
            if let fileURL = self.webFileManager.prepareWebView() {
                print("WebView base URL: \(fileURL.deletingLastPathComponent())") // Add this print statement
                print("loading file url: \(fileURL)... ")
                self.webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
            }
        }
        print("finished view did load in the view controller... ")
    }

    
    // Implement the required method of the JavaScriptInterfaceDelegate protocol
    func javascriptInterface( _ javascriptInterface: JavaScriptInterface, didReceiveMessage message: WKScriptMessage ) {
        print( "Received message from JavaScript: \( message.body )" )} // Example: print the message body
    
    func setupWebView() {
        print("setting up web view... ")
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
        print("    adding user script... ")
        contentController.addUserScript(userScript)
        let javaScriptLogger = JavaScriptLogger()
        print("    adding javascript logger... ")
        contentController.add(javaScriptLogger, name: "jsLog")
        errorLoggingScriptMessageHandler = ErrorLoggingScriptMessageHandler() // Initialize the instance
        print("    adding error logging script message handler... ")
        contentController.add(errorLoggingScriptMessageHandler, name: "errorLog") // Add the retained instance
    }

}


