//
//  boxesTests.swift
//  boxesTests
//
//  Created by Clay Ackerland on 4/13/23.
//

import XCTest
import WebKit
@testable import boxes

class boxesTests: XCTestCase {

    // ... Your existing boxesTests code ...

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
        
        javascriptInterface.executeJavaScript(script) { (result: Result<Any, Error>) in
            switch result {
            case .success(let html):
                XCTAssertNotNil(html, "The HTML content should not be nil.")
            case .failure(let error):
                XCTFail("Error executing JavaScript: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testUserContentControllerDidReceiveScriptMessage() {
        class JavaScriptInterfaceDelegateMock: JavaScriptInterfaceDelegate {
            var didReceiveMessageExpectation: XCTestExpectation
            
            init(didReceiveMessageExpectation: XCTestExpectation) {
                self.didReceiveMessageExpectation = didReceiveMessageExpectation
            }
            
            func javascriptInterface(_ javascriptInterface: JavaScriptInterface, didReceiveMessage message: WKScriptMessage) {
                XCTAssertEqual(message.body as? String, "Hello from JavaScript!", "Received message should match expected value.")
                didReceiveMessageExpectation.fulfill()
            }
        }
        
        let didReceiveMessageExpectation = XCTestExpectation(description: "Received message from JavaScript")
        
        javascriptInterface.delegate = JavaScriptInterfaceDelegateMock(didReceiveMessageExpectation: didReceiveMessageExpectation)
        
        let scriptMessage = WKScriptMessage(name: "MyApp", body: "Hello from JavaScript!", frameInfo: WKFrameInfo(mainFrame: true), world: WKContentWorld.defaultClient)
        
        javascriptInterface.userContentController(WKUserContentController(), didReceive: scriptMessage)
        
        wait(for: [didReceiveMessageExpectation], timeout: 5.0)
    }
}
