//
//  WebViewNavigationHandler.swift
//  boxes
//
//  Created by Clay Ackerland on 4/15/23.
//

import Foundation
import UIKit
import WebKit

class WebViewNavigationHandler {
    
    // constructor
    init() {
        print( "initializing WebViewNavigationHandler... " )
    }
    
    func handleNavigation(for request: URLRequest) -> Bool {
        // let mainInstance = McbaConfiguration.sharedInstance()
        // let mLibraryBundle = Bundle(identifier: "awm.ios.mcba.mLibrary")
        // let mainStoryBoard = UIStoryboard(name: "mcbaStoryboard", bundle: mLibraryBundle)

        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            // let requestString = request.url?.absoluteString

            // The same conditions from the original code

            // Examples:
            // if (requestString!.containsIgnoringCase(find: "chat")) { ... }
            // if (requestString!.containsIgnoringCase(find: "rewards")) { ... }
        }
        return true
    }
}
