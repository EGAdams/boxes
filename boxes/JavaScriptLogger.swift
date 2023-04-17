//
//  JavaScriptLogger.swift
//
//  Created by Clay Ackerland on 4/17/23.
//

import Foundation
import WebKit

class JavaScriptLogger: NSObject, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "jsLog", let logMessage = message.body as? String {
            print("[JavaScript]: \(logMessage)")
        }
    }
}
