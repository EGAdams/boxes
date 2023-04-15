//
//  JavascriptExecutor.swift
//
//  Created by Clay Ackerland on 4/15/23.
//
import Foundation
import WebKit

class JavaScriptExecutor {
    var webView: WKWebView!

    init( webView: WKWebView ) { self.webView = webView }

    func runJs(_ js: String) {
        webView.evaluateJavaScript(js) { (result, error) in
            if error != nil { print(error!.localizedDescription) }
        }}

    func bindDeviceFunctions() {
        let cmd = "" // The same JavaScript string from the original code
        runJs(cmd)}
}
