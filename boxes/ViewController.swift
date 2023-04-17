import UIKit
import WebKit

/** @class ViewController */
class ViewController: UIViewController, JavaScriptInterfaceDelegate {
    var webView: WKWebView!
    private var javascriptBridge: WKUserContentController!
    private var javascriptInterface: JavaScriptInterface!
    private var loggingNavigationDelegate: LoggingNavigationDelegate!
    
    private let webFileManager = WebFileManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filesToDownload: [URL: String] = [
            URL(string: "https://americansjewelry.com/chat/chat.html")!: "chatHTML",
            URL(string: "https://americansjewelry.com/chat/config.json")!: "configJSON",
            URL(string: "https://americansjewelry.com/chat/css/chat.css")!: "chatCSS",
            URL(string: "https://americansjewelry.com/chat/js/chat.js")!: "chatJS",
        ]
        
        webFileManager.downloadFiles(files: filesToDownload) { [weak self] in
            guard let self = self else { return }
            if let fileURL = self.webFileManager.prepareWebView() {
                self.setupWebView()
                self.webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
            }
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
    }
}


