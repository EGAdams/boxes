////
////  JavaScriptCommandHandler.swift
////  boxes
////
////  Created by Clay Ackerland on 4/14/23.
////
//
//import Foundation
//
//// Define custom delegate to handle WebView related events
//protocol JavascriptInterfaceDelegate: AnyObject {
//    func onPageLoaded(_ page: String)
//    func setTemplateRoot(_ root: String)
//    func exit() }
//
//// Define JavaScript Command Handler
//class JavaScriptCommandHandler {
//    func handleCommand(_ command: String, _ params: [String]) {
//        switch command {
//        case "onPageLoaded":
//            delegate?.onPageLoaded(params[1])
//        case "setTemplateRoot":
//            delegate?.setTemplateRoot(params[1])
//        case "onMcbaReady":
//            print("calling onMcbaReady()... ")
//            onMcbaReady()
//        case "exit":
//            delegate?.exit()
//        case "log":
//            log(params[1])
//        default:
//            break
//        }}
//    
//    func log(_ text: String!) { debugPrint( "MCBA log: " + text )}
//    
//    func onMcbaReady() {
//        print("Mcba ready")
//        self.mcbaReady = true
//        if mmcbaReadyCallback != nil { mmcbaReadyCallback!() }
//        print( "calling MCBA.load()... " )
//        runJs( "MCBA.load();" )}
//    
//    weak var delegate: JavascriptInterfaceDelegate?
//    var mcbaReady = false
//    var mmcbaReadyCallback: McbaReadyCallback?
//    var runJs: ((String) -> Void)!
//}
