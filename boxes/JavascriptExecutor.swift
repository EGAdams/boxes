//
//  JavascriptExecutor.swift
//
//  Created by Clay Ackerland on 4/15/23.
//
import Foundation
import WebKit

class JavaScriptExecutor {
    var webView: WKWebView!
    init( webView: WKWebView ) { 
        print( "initializing JavaScriptExecutor... " )
        self.webView = webView }

    func runJs(_ js: String, completionHandler: @escaping (Result<Any, Error>) -> Void) {
        let wrappedJS = """
        try {
            \(js)
        } catch (error) {
            const errorInfo = {
                message: error.message,
                line: error.line,
                column: error.column,
                sourceURL: error.sourceURL
            };
            window.webkit.messageHandlers.errorLog.postMessage(errorInfo);
            throw error;
        }
        """

        // Add the custom JavaScript error message handler
        // webView.configuration.userContentController.add(self, name: "jsError")

        webView.evaluateJavaScript(wrappedJS) { (result, error) in
            if let error = error {
                completionHandler(.failure(error))
            } else {
                guard let result = result else { return }
                completionHandler(.success(result))
            }
        }
    }

    func completionHandler(result: Result<Any, Error>) {
        switch result {
        case .success(let html):
            print(html)
        case .failure(let error):
            print(error.localizedDescription)
        }
    }

    func bindDeviceFunctions() {
        let cmd = """
        var Device = {
            setTemplateRoot : function(root){},
            onPageLoaded : function(page){ window.location = 'mcba-ios:onPageLoaded/'+page; },
            onScriptLoaded : function(src){ },
            showToast : function(msg){ window.location = 'mcba-ios:showToast'; },
            onMcbaReady : setTimeout( function(){ window.location = 'mcba-ios:onMcbaReady'; }, 500 ),
            exit : function(){}
        };
        console = new Object();
        console.log = function(text){
            window.location = 'mcba-ios:log/'+text;
        };
        console.debug = console.log;
        console.info = console.log;
        console.warn = console.log;
        console.error = console.log;
        """
        runJs(cmd, completionHandler: completionHandler)
    }
}
