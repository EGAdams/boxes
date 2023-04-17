import Foundation
import UIKit
typealias CompleteHandlerBlock = () -> ()
typealias DownloadFinishedCallback = ( _ location: URL?) -> ()
struct SessionId {
    static let IDENTIFIER: String = "awm.mcba"
    static var index: Int = 0 }
protocol McbaUpdateManagerClassDelegate {
    func McbaUpdateManagerShowMessage(      _ sender:McbaUpdateManager, message:            String )
    func McbaUpdateManagerFailedConnection( _ sender:McbaUpdateManager, isConnected:        Bool )
    func McbaUpdateManagerProgressUpdate(   _ sender:McbaUpdateManager, currentProgress:    Float )
    func McbaUpdateManagerProgressComplete( _ sender:McbaUpdateManager, currentProgress:    Float ) }
class McbaUpdateManager : NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
     private static var __once: () = {
            var instance            = McbaUpdateManager()
            instance.handlerQueue   = [String : CompleteHandlerBlock]()
            instance.callbackQueue  = [String : DownloadFinishedCallback]()}()
    
    let ajax = Ajax()
    var delegate:       McbaUpdateManagerClassDelegate?
    let curProgress:    Float  = 0;
    var handlerQueue:   [String: CompleteHandlerBlock]!
    var callbackQueue:  [String: DownloadFinishedCallback]!
    var lock = CountDownLock( count: 2 )
    var latitude = "";
    var longitude = "";
    var legalname = "";
    var viewController: ViewController?
    
    public func setViewController( viewControllerArg: ViewController ) { viewController = viewControllerArg }
     static var shared: McbaUpdateManager = {  // start singleton style initialization
        let instance            = McbaUpdateManager()
        instance.handlerQueue   = [String : CompleteHandlerBlock]()
        instance.callbackQueue  = [String : DownloadFinishedCallback]()
        return instance }()
    private override init() {
        super.init()
        self.ajax.sendLog( class_method: "\(#function )" + ": " + "\(#line )", message: "mcba update manager initializing..." )
        let mcbaConfiguration = McbaConfiguration.sharedInstance()
        lock = mcbaConfiguration.getLock() as! CountDownLock }
    class func sharedInstance() -> McbaUpdateManager { return shared } // </ end Singleton style initialization> 
    /* Autoincrement session id */
    var nextSessionId: String {
        let sessionIdOriginal   = SessionId.index
        SessionId.index         = SessionId.index + 1
        return SessionId.IDENTIFIER + String( sessionIdOriginal )}
    
    func updateMcba( _ callback: @escaping (()->Void ) ){
        let mainInstance = McbaConfiguration.sharedInstance()
        if !Reachability.isConnectedToNetwork() {
            self.delegate?.McbaUpdateManagerFailedConnection( self, isConnected: false )
            print( "Not connected" )}
        let downloadRoot = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true )[0] + ""
        mainInstance.setMcbaBaseUrl( baseUrlArg: mainInstance.getBaseUrl() + mainInstance.getMcbaDir())
        let BASE_URL = mainInstance.getMcbaBaseUrl().replacingOccurrences( of: "plugins/MCBA-Wordpress", with: "" )
        let DOWNLOAD_URL = BASE_URL + mainInstance.getWpBaseUrl()
        self.download( DOWNLOAD_URL + "sitemap.php" ) {
            ( location: URL?) in
            if location != nil {                
                let data = try? Data( contentsOf: location!)
                var progressMax: Int = 0
                if data == nil {
                    print( "ERROR data is nil RETURNING" )
                    return }
                var json: NSDictionary! = nil
                do {
                    json = try JSONSerialization.jsonObject( with: data!, options: .mutableContainers ) as! NSDictionary
                    //print("json is valid I think" )
                } catch _ {
                    self.ajax.sendLog( class_method: "\(#function )" + ": " + "\(#line )", message: "Uh oh, something wrong with json" )
                    return }
                let map: [String]? = json["map"] as! NSArray as? [String]
                var queueIndex = 0                                      /* Queue all new files from sitemap */
                var fileQueue: [Int : String] = [Int : String]()
                for val in map! {
                    let BASE_URL = mainInstance.getMcbaBaseUrl().replacingOccurrences( of: "plugins/MCBA-Wordpress", with: "" )
                    let DOWNLOAD_URL = BASE_URL + mainInstance.getWpBaseUrl()
                    let url = DOWNLOAD_URL + val
                    let destUrl = downloadRoot + "/www/" + val
                    if !FileManager.default.fileExists( atPath: destUrl ){
                        fileQueue[queueIndex] = url
                        queueIndex = queueIndex + 1 }} 
                progressMax = fileQueue.count
                print( "\( fileQueue.count ) URLS in queue" ) /* Download files in queue */
                self.downloadURLQueue( fileQueue ){
                    ( id: Int, origPath: String, newPath: URL?) in
                    if newPath != nil {
                        fileQueue.removeValue( forKey: id )
                        // print("Files left: \( fileQueue.count )" )
                        
                        if ( fileQueue.count > 0 && progressMax > 0 ) {
                            let curProgress: Float = Float( fileQueue.count ) / Float( progressMax )
                            GlobalVariables.curProgress = curProgress
                            self.delegate?.McbaUpdateManagerProgressUpdate( self, currentProgress: curProgress )}

                        if fileQueue.count < 2 {
                            self.delegate?.McbaUpdateManagerProgressComplete( self, currentProgress: 100 )
                            callback() }
                    } else { print( "File not saved" )}}}}} // end of updateMcba()

    func getMcbaConfig( _ callback: @escaping (( URL?)->()) ){
        let mainInstance = McbaConfiguration.sharedInstance()
        mainInstance.setMcbaBaseUrl( baseUrlArg: mainInstance.getBaseUrl() + mainInstance.getMcbaDir())        
        let BASE_URL = mainInstance.getMcbaBaseUrl().replacingOccurrences( of:"plugins/MCBA-Wordpress", with: "" )        
        let DOWNLOAD_URL = BASE_URL + mainInstance.getWpBaseUrl()
        self.ajax.sendLog( class_method: "\(#function )" + ": " + "\(#line )", message: "downloading app_config.json..." )
        self.download( DOWNLOAD_URL + "app_config.json", callback: callback )}
    func downloadURLQueue( _ queue: [Int : String], callback: (( Int, String, URL?) -> Void )? ){
        for ( id, fileUrl ) in queue  {
            self.download( fileUrl ){
                ( newLocation: URL?) in
                if callback != nil { callback!( id, fileUrl, newLocation )}}}} // end of downloadURLQueue()
    func download( _ _url: String, callback: DownloadFinishedCallback? ){
        var url: String!
        if ( _url.range( of: "php", options: NSString.CompareOptions.backwards ) != nil ) {
            url = _url + "?mobile=true"
        } else { url = _url }
        url = url.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed )
        let id = self.nextSessionId
        if callback != nil { addDownloadFinishedCallback( callback!, identifier: id )}
        let configuration = URLSessionConfiguration.background( withIdentifier: id )
        let backgroundSession = Foundation.URLSession( configuration: configuration, delegate: self, delegateQueue: nil )
        let requestUrl = URL( string: url )
        if  ( requestUrl != nil ) {
            let request = URLRequest( url: requestUrl!)
            let downloadTask = backgroundSession.downloadTask( with: request )
            downloadTask.taskDescription = id
            downloadTask.resume()
        } else { print("BAD URL: \( url )" )}} // end of download()
    func urlSession( _ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL ) {        
        let url: String! = downloadTask.originalRequest!.url!.absoluteString.removingPercentEncoding
        var dest: String
        let range = url.range( of: "/www/" )
        if range != nil{
            dest = String( url[range!.lowerBound...])
        } else { dest = "" }
        dest = dest.replacingOccurrences( of: "php", with: "html" )        
        let downloadRoot = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true )[0] + ""        
        let tempFilePath = downloadRoot + dest
        let result = matches( for: "(( http[s]?|ftp|file ):\\/)?\\/?([^:\\/\\s]+)((\\/\\w+)*\\/)([\\w\\-\\.]+[^#?]+)", in: tempFilePath )
        let filePath = result[0]   // end filePath mutation   
        let fileNameStartLoc = filePath.range( of: "/", options:NSString.CompareOptions.backwards )
        let directory = ( String( filePath[..<fileNameStartLoc!.lowerBound])) // use range instead of substring -EG
        do { try FileManager.default.createDirectory( atPath: directory, withIntermediateDirectories: true, attributes: nil )}
        catch let error as NSError { print( "ERROR creating directory: \( error.localizedDescription )" )}        
        if !FileManager.default.fileExists( atPath: directory ){ print( "ERROR creating directory at \( directory )" )}        
        if ( FileManager.default.fileExists( atPath: filePath )){
            do { try FileManager.default.removeItem( atPath: filePath )} catch let error as NSError { 
                print("*** ERROR deleting file: \( error.localizedDescription ) ***" )}}        
        do { try FileManager.default.moveItem( at: location, to: URL( fileURLWithPath: filePath ))
            if( filePath.contains("index.html" )) { //  refresh the web view once we know index.html is safely tucked away
                if( FileManager.default.fileExists( atPath: filePath )) {
                    DispatchQueue.main.async {
                        self.lock.countDown()
                        self.viewController?.refreshWebView()
                    }}} // end of if( filePath.contains("index.html" ))
            if( filePath.contains("app_config.json" )) {
                let path=URL( fileURLWithPath: filePath )
                let text=try? String( contentsOf: path )
                var app_config = try! String( contentsOf: path, encoding: .utf8 )
                let converter = StringToJsonConverter()
                let convertedAppConfig  = converter.execute( textToConvert: app_config )
                let takeVarOff      = text!     .replacingOccurrences( of: "var config_data = ", with: ""  )
                var originalText    = takeVarOff.replacingOccurrences( of: "\\\"", with: "\"" )
                //originalText = originalText.replacingOccurrences( of: " ", with: "" )
                originalText = originalText.replacingOccurrences( of: "\\n", with: "" )
                originalText = originalText.replacingOccurrences( of: "\\/", with: "" )
                originalText = originalText.replacingOccurrences( of: "&", with: "" )
                originalText = originalText.replacingOccurrences( of: ";", with: "" )
                let notagText = originalText.withoutHtmlTags            
                struct GenericOptions : Decodable {
                    let text    : String
                    let type    : String
                    let value   : String } 
                struct LegalName : Decodable {
                    let legalname : GenericOptions } 
                struct Coordinate : Decodable {
                    let latitude  : GenericOptions
                    let longitude : GenericOptions
                    let legalname : GenericOptions }
                struct Main : Decodable {
                    let template: String
                    let options:  Coordinate }
                let jsonData = notagText.data( using: .utf8 )!
                do { let jsonDecoder = JSONDecoder()
                     let main = try jsonDecoder.decode( Main.self, from: jsonData )
                     self.latitude = main.options.latitude.value
                     self.longitude = main.options.longitude.value
                     self.legalname = main.options.legalname.value
                } catch { print("Unexpected error: \( error )." )}}} // end of if( filePath.contains("app_config.json" ))
        catch let error as NSError { print( "*** ERROR: moving from: \( location ) to \( filePath ): \( error.localizedDescription ) ***" )}
        callCallback( downloadTask.taskDescription, location: URL( fileURLWithPath: filePath ))} // lock.countDown() ???
    
    func addDownloadFinishedCallback( _ callback: @escaping DownloadFinishedCallback, identifier: String ) { callbackQueue[identifier] = callback }
    func addCompletionHandler( _ handler: @escaping CompleteHandlerBlock, identifier: String ) {
        self.ajax.sendLog( class_method: "\(#function )" + ": " + "\(#line )", message: "adding completion handler..." )
        handlerQueue[identifier] = handler }
    func callCallback( _ identifier: String!, location: URL? ) {
        DispatchQueue.main.async {
            if let callback: DownloadFinishedCallback = self.callbackQueue[identifier] {
                self.callbackQueue!.removeValue( forKey: identifier )
                if location != nil {
                    callback( location )
                } else { callback( nil )}}} // end of DispatchQueue.main.async {
        } // wrapped on Saturday Novemer 16, 2019.  callbackQueue!.removeValue( forKey: identifier ) is throwing EXC_BAD_ACCESS ( code=1, address=ox5001e ) error
    func callCompletionHandlerForSession( _ identifier: String!) {
        self.ajax.sendLog( class_method: "\(#function )" + ": " + "\(#line )", message: "call background completion handler callback" )
        self.ajax.sendLog( class_method: "\(#function )" + ": " + "\(#line )", message: "identifier \( String( describing: identifier )) handlerQueue: " + String( describing: handlerQueue ))
        if  var _: CompleteHandlerBlock = handlerQueue[ identifier ] { if ( handlerQueue[identifier] != nil ) { handlerQueue!.removeValue( forKey: identifier )}}}
    func urlSessionDidFinishEvents( forBackgroundURLSession session: URLSession ) {
        if !session.configuration.identifier!.isEmpty {
            self.ajax.sendLog( class_method: "\(#function )" + ": " + "\(#line )", message: "mcbaCompletion Handler BACKGROUND" )
            callCompletionHandlerForSession( session.configuration.identifier )}}
    func urlSession( _ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("ERROR - didBecomeInvalidWithError: \( String( describing: error?.localizedDescription ))." )}
    func urlSession( _ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping ( URLSession.AuthChallengeDisposition, URLCredential?) -> Void ) {
        self.ajax.sendLog( class_method: "\(#function )" + ": " + "\(#line )", message: "mcbaReceived challenge" )
        completionHandler( Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential( trust: challenge.protectionSpace.serverTrust!))}
    func urlSession( _ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64 ) {}    
    func urlSession( _ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
            print( "Completed successfully." )       
        } else { print("Failed, error: \( String( describing: error?.localizedDescription ))" )}}
    
    func urlSession( _ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64 ) {
        print("Download resumed at offset \( fileOffset ) bytes out of an expected \( expectedTotalBytes ) bytes." )}
    func matches( for regex: String, in text: String ) -> [String] {
        do {
            let regex = try NSRegularExpression( pattern: regex )
            let results = regex.matches( in: text, range: NSRange( text.startIndex..., in: text ))
            return results.map { String( text[Range($0.range, in: text )!])}
        } catch let error {
            print("invalid regex: \( error.localizedDescription )" )
            return [] }} // end regex
    func printAttributes( filename: String ) -> Void {
        let fileManager = FileManager()
        do { // Get attributes of 'myfile.txt' file
            // let attributes = try fileManager.attributesOfItemAtPath( filename )
            let attributes = try fileManager.attributesOfItem( atPath: filename )
            print( attributes )}

        catch let error as NSError {
            print("Ooops! Something went wrong: \( error )" )}}
} // </ McbaUpdateManager>