//
//  PushNotificationRegisterer.swift
//
//  Created by Clay Ackerland on 4/15/23.
//
import Foundation
import WebKit

class PushNotificationRegisterer {
    var webView: WKWebView!
    init(webView: WKWebView) { self.webView = webView }
    
    func completionHandler(result: Result<Any, Error>) {
        switch result {
        case .success(let html):
            print( html)
        case .failure(let error):
            print( error.localizedDescription )}}

    func registerForPush(url: String, mcbaId: Int, id: String) {
        let jsExecutor = JavaScriptExecutor(webView: webView)
        let stringToExecute = "MCBA.registerPushId('\(url)', \(mcbaId),'\(UIDevice.current.model)', 2,'\(id)');"
        jsExecutor.runJs(stringToExecute, completionHandler: completionHandler)
    }
}
