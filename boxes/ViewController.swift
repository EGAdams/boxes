import UIKit
import WebKit

/** @class ViewController */
class ViewController: UIViewController, JavaScriptInterfaceDelegate {
    var webView: WKWebView!
    private var javascriptBridge: WKUserContentController!
    private var javascriptInterface: JavaScriptInterface!
    private var loggingNavigationDelegate: LoggingNavigationDelegate!
    
    // Add the WebFileManager instance
    private let webFileManager = WebFileManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Define the filesToDownload dictionary
        let filesToDownload: [URL: String] = [
            URL(string: "http://americansjewelry.com/chat/chat.html")!: "chat.html",
            URL(string: "http://americansjewelry.com/chat/config.json")!: "config.json",
            URL(string: "http://americansjewelry.com/chat/css/chat.css")!: "chat.css",
            URL(string: "http://americansjewelry.com/chat/js/chat.js")!: "chat.js",
        ]
        
        // Replace the downloadFiles() call with webFileManager.downloadFiles()
        webFileManager.downloadFiles(files: filesToDownload) { [weak self] in
            self?.webFileManager.prepareWebView()
        }
    }
    
    // Implement the required method of the JavaScriptInterfaceDelegate protocol
    func javascriptInterface(_ javascriptInterface: JavaScriptInterface, didReceiveMessage message: WKScriptMessage) {
        // Example: print the message body
        print("Received message from JavaScript: \(message.body)")
    }
}



