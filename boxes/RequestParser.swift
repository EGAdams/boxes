//
//  RequestParser.swift
//  boxes
//
//  Created by Clay Ackerland on 4/15/23.
//

import Foundation

class RequestParser {
    func parseRequest(_ request: URLRequest, with javascriptInterface: JavaScriptInterface) {
        if let url = request.url, url.scheme == "mcba-ios" {
            let urlString = url.absoluteURL.absoluteString.replacingOccurrences(of: "mcba-ios:", with: "")
            let params = urlString.components(separatedBy: "/")
            let funcName = params[0]

            switch funcName {
            case "onPageLoaded":
                print("Page Loaded: \(params[1])")
            case "setTemplateRoot":
                print("Template root: \(params[1])")
            case "onMcbaReady":
                McbaConfiguration.sharedInstance().setMcbaReady(ready: true)
                if let callback = javascriptInterface.mcbaReadyCallback {
                    callback()
                }
                let jsExecutor = JavaScriptExecutor(webView: javascriptInterface.webView)
                jsExecutor.runJs("MCBA.load();")
            case "exit":
                print("exiting...")
            case "log":
                print("MCBA log: \(params[1])")
            default:
                break
            }
        }
    }
}
