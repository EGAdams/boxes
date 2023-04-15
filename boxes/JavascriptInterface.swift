//import UIKit
//import WebKit
//import Foundation
//import CoreData
//
//typealias McbaReadyCallback = () -> ()
//class JavascriptInterface: NSObject, WKScriptMessageHandler, JavascriptInterfaceDelegate {
//    
//    func setTemplateRoot(_ root: String) {
//        print( "*** TODO: set template root! ***" )
//    }
//    
//    let scheme = "mcba-ios"
//    var webView: WKWebView!
//    
//    // Initialize the JavaScriptCommandHandler
//    let jsCommandHandler = JavaScriptCommandHandler()
//
//    init(view: WKWebView!) {
//        print("*** INITIALIZING JAVASCRIPT OBJECT HERE. ***")
//        webView = view
//        super.init()
//        webView.configuration.userContentController.add(self, name: "MCBA")
//        jsCommandHandler.delegate = self
//        jsCommandHandler.runJs = { [weak self] js in
//            self?.webView.evaluateJavaScript(js) { (result, error) in
//                if error != nil {
//                    print(error!.localizedDescription)
//                }
//            }
//        }
//        bind()}
//    
//    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        if message.name == "MCBA" {
//            guard let urlString = message.body as? String,
//                  let url = URL(string: urlString) else {
//                return
//            }
//            let request = URLRequest(url: url)
//            parseRequest(request) }}
//    
//    func bind() {
//        let cmd = "var Device = { " +
//            "setTemplateRoot : function(root){}," +
//            "onPageLoaded : function(page){ window.location = 'mcba-ios:onPageLoaded/'+page; }," +
//            "onScriptLoaded : function(src){ }," +
//            "showToast : function(msg){ window.location = 'mcba-ios:showToast'; }," +
//            "onMcbaReady : setTimeout( function(){  window.location = 'mcba-ios:onMcbaReady';}, 500 );," +
//            "exit : function(){}" +
//        "};" +
//        "console = new Object();" +
//        "console.log = function(text){" +
//            "window.location = 'mcba-ios:log/'+text;" +
//        "};" +
//        "console.debug = console.log;" +
//        "console.info = console.log;" +
//        "console.warn = console.log;" +
//        "console.error = console.log;"
//        jsCommandHandler.runJs( cmd ) }
//
//    func parseRequest(_ request: URLRequest!) {
//        if request == nil {
//            print("request is nil!  returning... ")
//            return }
//        if request.url!.scheme == self.scheme {
//            let urlString = request.url!.absoluteURL.absoluteString.replacingOccurrences(of: self.scheme + ":", with: "")
//            let params = urlString.components(separatedBy: "/")
//            let funcName = params[0]
//            print("funcName:\(funcName)")
//            jsCommandHandler.handleCommand(funcName, params) }}
//
//    func log(_ text: String!) { print("JS Log: \(text ?? "")")}
//
//    func onPageLoaded(_ page: String) { print("Page Loaded: \(page)")}
//
//    func setTemplateRoot(_ root: String!) { print("Template root: " + root) }
//
//    func exit() { print("exiting... ") }
//}
