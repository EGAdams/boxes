//
//  McbaConfiguration.swift
//  boxes
//
//  Created by Clay Ackerland on 4/15/23.
//
//  Created by Clay Ackerland on 11/23/16.
//  Copyright © 2016 All Web n Mobile. All rights reserved.
//

import Foundation


import Foundation


public class McbaConfiguration {
    
    // These are the ONLY things you should change here
    var MCBA_ID = 55
    var MCBA_BASE_URL   = "https://floridascarwash.com/wp-content/plugins/MCBA-Wordpress/"
    var BASE_URL        = "https://floridascarwash.com/"
    
    // The base URL will get changed by the master server
    var DEVELOPER_MODE = false
    var MCBA_REG_FILE   = "registerMCBA.php"
    var MCBA_PROXY_URL  = "http://mycustombusinessapp.com/MCBA-MasterServer/register.php"
    var WP_BASE_URL     = "uploads/MCBA/www/"
    var GCM_ID          = ""
    var GCM_TOKEN       = ""
    var MCBA_DIR        = "wp-content/plugins/MCBA-Wordpress/"
    var MASTER_DIR      = "MCBA-MasterServer"
    var SHOP_DIR        = "shop/shop/"
    var NAME            = ""
    
    var destination     = ""
//    var customController: UINavigationController? = nil
//    var customControllerInitialized = false
//    var originalViewController: UIViewController? = nil
//    var friendsController: FriendsController? = nil
//    var isAdministrator = false
//    var threadLock = CountDownLock(count: 1)
    var javascriptInitialized = false
    var mcbaReady = true
    
    public func isMcbaReady() -> Bool {
        return mcbaReady
    }
    
    ////////////////////////////////////// getters / setters /////////////////////////////////////////

    public func setMcbaReady( ready: Bool ) {
        self.mcbaReady = ready
    }
//    public func getLock() -> Any {
//        return threadLock
//    }
    
    public func isJavascriptInitialized() -> Bool {
        if (javascriptInitialized) {
            return true
        }else{
            return false
        }
    }
    
    
//    public func getCustomControllerInitialized() -> Bool {
//        return customControllerInitialized
//    }
//    
//    public func setAdmin() {
//        isAdministrator = true
//    }
//    
//    public func isAdmin() -> Bool {
//        return isAdministrator
//    }
    
//    public func setFriendsController(friendsControllerArg: FriendsController) {
//        self.friendsController = friendsControllerArg
//    }
//
//    public func getFriendsController() -> FriendsController {
//        return self.friendsController!
//    }
    
//    public func getCustomController() -> UINavigationController {
//        if(customControllerInitialized) {
//            return self.customController!
//        }else{
//            return UINavigationController()
//        }
//    }
//
//    public func setCustomController(controller: UINavigationController) {
//        customControllerInitialized = true
//        self.customController = controller
//    }
//
//    public func setOriginalViewController(viewController: UIViewController) {
//        self.originalViewController = viewController
//    }
//
//    public func getOriginalViewController() -> UIViewController {
//        return originalViewController!
//    }
    
    public func getMcbaId() -> Int {
        return MCBA_ID
    }
    public func setMcbaId(idArg: Int) {
        self.MCBA_ID = idArg
    }
    public func getMcbaBaseUrl() -> String {
        return self.MCBA_BASE_URL
    }
    public func setMcbaBaseUrl(baseUrlArg: String) {
        self.MCBA_BASE_URL = baseUrlArg
    }
    public func getBaseUrl() -> String {
        return self.BASE_URL
    }
    public func setBaseUrl(baseUrlArg: String) {
        self.BASE_URL = baseUrlArg
    }
    public func getName() -> String {
        return self.NAME
    }
    public func setName(nameArg: String) {
        self.NAME = nameArg
    }
    public func getDestination() -> String {
        return self.destination
    }
    public func setDestination(destinationArg: String) {
        self.destination = destinationArg
    }
    public func getGcmToken() -> String {
        return self.GCM_TOKEN
    }
    public func setGcmToken(gcmTokenArg: String) {
        self.GCM_TOKEN = gcmTokenArg
    }
    public func getGcmId() -> String {
        return self.GCM_ID
    }
    public func setGcmId(gcmIdArg: String) {
        self.GCM_ID = gcmIdArg
    }
    public func getDeveloperMode() -> Bool {
        return self.DEVELOPER_MODE
    }
    public func getMcbaRegFile() -> String {
        return self.MCBA_REG_FILE
    }
    public func getMcbaProxyUrl() -> String {
        return self.MCBA_PROXY_URL
    }
    public func getWpBaseUrl() -> String {
        return self.WP_BASE_URL
    }
    public func getMcbaDir() -> String {
        return self.MCBA_DIR
    }
    public func getMasterDir() -> String {
        return self.MASTER_DIR
    }
    public func setMcbaDir(mcbaDirArg: String) {
        self.MCBA_DIR = mcbaDirArg
    }
    public func getShopDir() -> String {
        return self.SHOP_DIR
    }
    public func setShopDir(shopDirArg: String) {
        self.SHOP_DIR = shopDirArg
    }
    ///////////////////////////////////////// </ getters / setters> ////////////////////////////////////////
    
    
    
    ///////////////////// Constructor: start Singleton style initialization /////////////////////
    private static var shared: McbaConfiguration = {
        let instance = McbaConfiguration()
        return instance
    }()
    
    private init() {
        print("*** Config: initializing configuration class... ***")
    }
    
    public class func sharedInstance() -> McbaConfiguration {
        return shared
    }
    ////////////////////// </ end Singleton style initialization> ////////////////////////////////
    
    
    /////////////////////////////// <isRegistered> /////////////////////////////////////
    public func isRegistered() -> Bool {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "first_name") != nil {
            //print("we appear to be registered as "+first_name)
            return true
        }
        //print ("we are NOT registered")
        return false
    }
    ////////////////////////////// </ isRegistered> ////////////////////////////////////
}
