import UIKit
import WebKit

// JavaScriptInterface.swift
class JavaScriptInterface: NSObject, WKScriptMessageHandler {
    
    weak var delegate: JavaScriptInterfaceDelegate?
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.javascriptInterface(self, didReceiveMessage: message)
        print(  "message.body: \(message.body)" )
    }
}

protocol JavaScriptInterfaceDelegate: AnyObject {
    func javascriptInterface(_ javascriptInterface: JavaScriptInterface, didReceiveMessage message: WKScriptMessage)
}

// ViewController.swift
class ViewController: UIViewController, JavaScriptInterfaceDelegate {
    
    var webView: WKWebView!
    private var javascriptBridge:           WKUserContentController!
    private var javascriptInterface:        JavaScriptInterface!
    private var loggingNavigationDelegate:  LoggingNavigationDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true  // this defaults to false.  we may need this.

        javascriptInterface = JavaScriptInterface()     // Initialize the JavaScriptInterface
        javascriptInterface.delegate = self
        
        // Set the WKUserContentController for the WKWebViewConfiguration
        webConfiguration.userContentController = WKUserContentController()
        
        // Add the JavaScriptInterface to the WKWebView
        webConfiguration.userContentController.add(javascriptInterface, name: "MyApp")
        webView = WKWebView(frame: view.frame, configuration: webConfiguration)
        loggingNavigationDelegate = LoggingNavigationDelegate()
        webView.navigationDelegate = loggingNavigationDelegate
        view.addSubview(webView)
        
        // Load the JavaScript file content from the app's resources
        guard let scriptPath = Bundle.main.path(forResource: "init", ofType: "js"),
              let _ = try? String(contentsOfFile: scriptPath) else {
            print("Failed to load the JavaScript file.")
            return }
        
        if let htmlFilePath = Bundle.main.path(forResource: "buttons", ofType: "html"), let htmlString = try? String(contentsOfFile: htmlFilePath) {
            webView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
        }
    }
    
    func javascriptInterface(_ javascriptInterface: JavaScriptInterface, didReceiveMessage message: WKScriptMessage) {
        print("Received message from JavaScript: \(message.body)")
    }
}
