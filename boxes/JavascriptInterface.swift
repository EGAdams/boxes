import UIKit
import WebKit

typealias McbaReadyCallback = () -> ()

protocol JavaScriptInterfaceDelegate: AnyObject {
    func javascriptInterface( _ javascriptInterface: JavaScriptInterface, didReceiveMessage message: WKScriptMessage )
}

class JavaScriptInterface: NSObject, WKScriptMessageHandler {
    let webView: WKWebView!
    var mcbaReadyCallback: McbaReadyCallback?
    var pushNotificationRegisterer: PushNotificationRegisterer
    var requestParser: RequestParser
    var webViewNavigationHandler: WebViewNavigationHandler
    var javaScriptExecutor: JavaScriptExecutor
    weak var delegate: JavaScriptInterfaceDelegate?

    init( webView: WKWebView ) {
        print( "initializing JavaScriptInterface... " )
        self.webView = webView
        pushNotificationRegisterer = PushNotificationRegisterer( webView: webView )
        requestParser = RequestParser()
        webViewNavigationHandler = WebViewNavigationHandler()

        javaScriptExecutor = JavaScriptExecutor( webView: webView )
        javaScriptExecutor.bindDeviceFunctions()

        if !McbaConfiguration.sharedInstance().isJavascriptInitialized() {
            McbaConfiguration.sharedInstance().javascriptInitialized = true }
        super.init()}

    func userContentController( _ userContentController: WKUserContentController, didReceive message: WKScriptMessage ) {
        print("Message received: \( message.body )")
        if message.name == "MCBA" {
            guard let urlString = message.body as? String,
                  let url = URL( string: urlString ) else { return }
            let request = URLRequest( url: url )
            requestParser.parseRequest( request, with: self )
            
        } else if message.name == "errorLog", let errorMessage = message.body as? String {
            print( "[Javascript]: \(errorMessage)")
        }
    }
    
    func setMcbaReadyCallback( _ callback: McbaReadyCallback! ) {
        if McbaConfiguration.sharedInstance().isMcbaReady() {
            callback()
        } else { self.mcbaReadyCallback = callback }}
    
    func webView( _ webView: WKWebView, shouldStartLoadWith request: URLRequest, navigationType: WKWebView.Type ) -> Bool {
        requestParser.parseRequest( request, with: self )
        return webViewNavigationHandler.handleNavigation( for: request )}
    
    func executeJavaScript( _ script: String, completionHandler: @escaping ( Result<Any, Error> ) -> Void ) {
        let jsExecutor = JavaScriptExecutor( webView: webView )
        jsExecutor.runJs( script, completionHandler: completionHandler ) }
}
