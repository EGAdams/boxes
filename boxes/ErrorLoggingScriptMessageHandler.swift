import Foundation
import WebKit

class ErrorLoggingScriptMessageHandler: NSObject, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print( "inside userContentController in ErrorLoggingScriptMessageHandler... message.name: \(message.name) " )
        if let errorInfo = message.body as? [String: Any] {
            let message = errorInfo["message"] as? String ?? "Unknown error"
            let source = errorInfo["source"] as? String ?? "Unknown source"
            let lineno = errorInfo["lineno"] as? Int ?? -1
            let colno = errorInfo["colno"] as? Int ?? -1
            let stack = errorInfo["stack"] as? String ?? "No stack trace available"
            print("JavaScript Error: \(message)\nSource: \(source)\nLine: \(lineno), Column: \(colno)\nStack trace:\n\(stack)")
        }}}
