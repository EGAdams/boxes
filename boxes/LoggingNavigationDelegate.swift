import Foundation
import WebKit

class LoggingNavigationDelegate: NSObject, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("Navigation request URL: \(navigationAction.request.url?.absoluteString ?? "unknown")") // Add this print statement
        
        if let url = navigationAction.request.url, url.scheme == "console-log" {
            print("[JavaScript console.log]:", url.absoluteString.removingPercentEncoding?.replacingOccurrences(of: "console-log://", with: "") ?? "")
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let jsFilePath = Bundle.main.path(forResource: "init", ofType: "js"), let jsString = try? String(contentsOfFile: jsFilePath) {
            webView.evaluateJavaScript(jsString, completionHandler: nil)
        }
    }
}
