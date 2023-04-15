//
//
//
import UIKit
import WebKit

typealias McbaReadyCallback = () -> ()

protocol JavaScriptInterfaceDelegate: AnyObject {
    func javascriptInterface(_ javascriptInterface: JavaScriptInterface, didReceiveMessage message: WKScriptMessage)
}

class JavaScriptInterface: NSObject, WKScriptMessageHandler {
    let webView: WKWebView!
    var mcbaReadyCallback: McbaReadyCallback?
    var pushNotificationRegisterer: PushNotificationRegisterer
    var requestParser: RequestParser
    var webViewNavigationHandler: WebViewNavigationHandler
    weak var delegate: JavaScriptInterfaceDelegate?

    init( webView: WKWebView ) {
        self.webView = webView
        pushNotificationRegisterer = PushNotificationRegisterer(webView: webView)
        requestParser = RequestParser()
        webViewNavigationHandler = WebViewNavigationHandler()

        super.init()
        let jsExecutor = JavaScriptExecutor( webView: webView )
        jsExecutor.bindDeviceFunctions()

        if !McbaConfiguration.sharedInstance().isJavascriptInitialized() {
            McbaConfiguration.sharedInstance().javascriptInitialized = true }}

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "MCBA" {
            guard let urlString = message.body as? String,
                  let url = URL(string: urlString) else { return }
            let request = URLRequest(url: url)
            requestParser.parseRequest( request, with: self )}}
    
    func setMcbaReadyCallback(_ callback: McbaReadyCallback!) {
        if McbaConfiguration.sharedInstance().isMcbaReady() {
            callback()
        } else { self.mcbaReadyCallback = callback }}
}

