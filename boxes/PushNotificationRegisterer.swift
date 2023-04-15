//
//  PushNotificationRegisterer.swift
//  boxes
//
//  Created by Clay Ackerland on 4/15/23.
//

import Foundation
import WebKit

class PushNotificationRegisterer {
    var webView: WKWebView!

    init(webView: WKWebView) {
        self.webView = webView
    }

    func registerForPush(url: String, mcbaId: Int, id: String) {
        let jsExecutor = JavaScriptExecutor(webView: webView)
        jsExecutor.runJs("MCBA.registerPushId('\(url)', \(mcbaId),'\(UIDevice.current.model)', 2,'\(id)');")
    }
}
