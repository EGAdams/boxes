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

    func runJs(_ js: String, completionHandler: @escaping (Result<Any, Error>) -> Void) {
        webView.evaluateJavaScript(js) { (result, error) in
            if let error = error {
                completionHandler(.failure(error))
            } else {
                // return if the result is nil
                guard result != nil else { return }
                completionHandler(.success(result!))
            }
        }
    }

    func completionHandler(result: Result<Any, Error>) {
        switch result {
        case .success(let html):
            print( html)
        case .failure(let error):
            print( error.localizedDescription )}}


    func bindDeviceFunctions() {
        let cmd = "" // The same JavaScript string from the original code
        runJs( cmd, completionHandler: completionHandler )
    }
}
