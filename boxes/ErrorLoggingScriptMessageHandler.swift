//
//  ErrorLoggingScriptMessageHandler.swift
//
//  Created by Clay Ackerland on 4/18/23.
//

import Foundation
import WebKit

class ErrorLoggingScriptMessageHandler: NSObject, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let errorInfo = message.body as? [String: Any] {
            let message = errorInfo["message"] as? String ?? "Unknown error"
            let source = errorInfo["source"] as? String ?? "Unknown source"
            let lineno = errorInfo["lineno"] as? Int ?? -1
            let colno = errorInfo["colno"] as? Int ?? -1
            let stack = errorInfo["stack"] as? String ?? "No stack trace available"
            
            print("JavaScript Error: \(message)\nSource: \(source)\nLine: \(lineno), Column: \(colno)\nStack trace:\n\(stack)")
        }
    }
}
