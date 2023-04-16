//
//  boxesTests.swift
//  boxesTests
//
//  Created by Clay Ackerland on 4/13/23.
//

import XCTest
import WebKit
@testable import boxes

class boxesTests: XCTestCase, JavaScriptInterfaceDelegate {
    var messageReceivedExpectation: XCTestExpectation!
    
    func javascriptInterface(_ javascriptInterface: JavaScriptInterface, didReceiveMessage message: WKScriptMessage) {
        print( "*** Handle the received message here... ***" )
    }

//    override func setUpWithError() throws {
//        // ...
//        javascriptInterface.delegate = self
//    }
}

class JavaScriptInterfaceTests: XCTestCase {
    
    var webView: WKWebView!
    var javascriptInterface: JavaScriptInterface!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        webConfiguration.userContentController = WKUserContentController()
        
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), configuration: webConfiguration)
        
        javascriptInterface = JavaScriptInterface(webView: webView)
    }
    
    override func tearDownWithError() throws {
        webView = nil
        javascriptInterface = nil
        
        try super.tearDownWithError()
    }
    
    func testJavaScriptInterfaceInitialization() {
        XCTAssertNotNil(javascriptInterface, "JavaScriptInterface should not be nil after initialization.")
    }
    
    func testExecuteJavaScript() {
        let expectation = XCTestExpectation(description: "Execute JavaScript")
        let script = "document.documentElement.outerHTML"
        
        func completionHandler(result: Result<Any, Error>) {
            switch result {
            case .success(let html):
                XCTAssertNotNil(html, "The HTML content should not be nil.")
            case .failure(let error):
                XCTFail("Error executing JavaScript: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }

        javascriptInterface.executeJavaScript( script, completionHandler: { (result: Result<Any, Error>) in
            switch result {
            case .success(let html):
                XCTAssertNotNil(html, "The HTML content should not be nil.")
            case .failure(let error):
                XCTFail("Error executing JavaScript: \(error.localizedDescription)")
            }
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 5.0)
    }



    func testUserContentControllerDidReceiveScriptMessage() {
        _ = XCTestExpectation(description: "Received message from JavaScript")
        
        print("Test started")
        
        let script = "window.webkit.messageHandlers.MyApp.postMessage('Hello from JavaScript!');"
        webView.evaluateJavaScript(script) { [weak self] (result, error) in
            if let error = error {
                print("Error executing JavaScript: \(error.localizedDescription)")
            } else {
                print("JavaScript executed")
                
//                let message = WKScriptMessage()
//                self?.javascriptInterface(self?.javascriptInterface, didReceiveMessage: message)
            }
            // print string describing self
            print( String(describing: self) )
        }
        
        // wait for timeout
        // wait(for: [messageReceivedExpectation], timeout: 5.0)
    }

}
