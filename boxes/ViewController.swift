import UIKit
import WebKit

/** @class ViewController */
class ViewController: UIViewController, JavaScriptInterfaceDelegate {
    var webView: WKWebView!
    private var javascriptBridge:           WKUserContentController!
    private var javascriptInterface:        JavaScriptInterface!
    private var loggingNavigationDelegate:  LoggingNavigationDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true           // this defaults to false.  we may need this.
        webConfiguration.userContentController = WKUserContentController()                  // Set the WKUserContentController
                                                                                            // for the WKWebViewConfiguration
        webView = WKWebView( frame: view.frame, configuration: webConfiguration )
        
        javascriptInterface = JavaScriptInterface( webView: webView )                       // Initialize the JavaScriptInterface
        javascriptInterface.delegate = self
        webConfiguration.userContentController.add( javascriptInterface, name: "MyApp" )    // Add the JavaScriptInterface
                                                                                            // to the WKWebView
        loggingNavigationDelegate = LoggingNavigationDelegate()
        webView.navigationDelegate = loggingNavigationDelegate
        view.addSubview( webView )
        guard let scriptPath = Bundle.main.path( forResource: "init", ofType: "js" ),// Load the JavaScript file 
                                                                                             // content from the app's resources
            let _ = try? String( contentsOfFile: scriptPath ) else {
            print ("Failed to load the JavaScript file." )
            return }
        
        if let htmlFilePath = Bundle.main.path( forResource: "buttons", ofType: "html" ), let htmlString = try? String( contentsOfFile: htmlFilePath ) {
            webView.loadHTMLString( htmlString, baseURL: Bundle.main.bundleURL )
        }}
    
    func javascriptInterface( _ javascriptInterface: JavaScriptInterface, didReceiveMessage message: WKScriptMessage ) {
        print ("Received message from JavaScript: \( message.body )" )}
}
