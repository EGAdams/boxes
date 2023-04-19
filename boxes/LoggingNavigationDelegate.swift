//
//  LoggingNavigationDelegate.swift
//
//  Created by Clay Ackerland on 4/14/23.
//

import Foundation
import WebKit

class LoggingNavigationDelegate: NSObject, WKNavigationDelegate, WKScriptMessageHandler { 
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == "console-log" {
            print("[JavaScript console.log]:", url.absoluteString.removingPercentEncoding?.replacingOccurrences(of: "console-log://", with: "") ?? "")
            decisionHandler(.cancel)
            return
        }
        decisionHandler( .allow )}
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let jsFilePath = Bundle.main.path(forResource: "init", ofType: "js"), let jsString = try? String(contentsOfFile: jsFilePath) {
            webView.evaluateJavaScript(jsString, completionHandler: nil)
        }}
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print( "inside userContentController in LoggingNavigationDelegate... message.name: \(message.name) " )
        if message.name == "jsLog" {
            print("JavaScript Log: \(message.body)")
        }}
}
