//
//  VCHTTPConnect.swift
//  TimeClockBadge
//
//  Created by Vitor Cesco on 8/25/16.
//  Copyright © 2016 Rolfson Oil. All rights reserved.
//

import Foundation
import Alamofire

/** Shared VCConnectionManager. Update it's activeConnection to swap between online and offline mode. */
public let sharedConnectionManager: VCConnectionManager = VCConnectionManager()

/** Responsible for managing the active ConnectionState used on Datastore loading. */
open class VCConnectionManager {
    public enum ConnectionState {
        case online, offline
    }
    
    public enum ConnectionNotification: String {
        case stateChanged = "VCConnectionManagerStateChangedNotification"
    }
    
    open var state: ConnectionState = .online {
        didSet {
            NotificationCenter.default.post(name: Notification.Name.init(rawValue: ConnectionNotification.stateChanged.rawValue), object: nil, userInfo: nil)
        }
    }
    
    public init() {
        
    }
    
    /** Verifies if the device has Internet Connection */
    open func checkConnectivity(completion: @escaping ((Bool) -> Void)) -> Void {
        if NetworkReachabilityManager()!.isReachable {
            let connector = VCHTTPConnect(url: "https://www.google.com",
                                          parameters: [:],
                                          headers: ["Cache-Control":"no-cache"])
            connector.get(path: "", handler: {_, response in
                completion(response.statusCode == 200)
            })
        }
        else {
            completion(false)
        }
    }
}

open class VCHTTPConnect {
    
    // Object used to represent a response from an HTTP call
    public struct HTTPResponse {
        // Status code of the connections
        public let statusCode : Int?
        // Error occurred on the connection
        public let error : Error?
        // Headers returned on the connection
        public let headers : [String:String]?
        // URL returned on the connection
        public let url : URL?
        // Data returned on the connection
        public let data : Data?
        
        /** Initializes this HTTPResponse with an Alamofire Response object. */
        public init(response: DataResponse<Data>) {
            self.statusCode = response.response?.statusCode
            self.error = response.error
            self.headers = response.response?.allHeaderFields as? [String : String]
            self.url = response.response?.url
            self.data = response.data
        }
        public init(response: DataResponse<Any>) {
            self.statusCode = response.response?.statusCode
            self.error = response.error
            self.headers = response.response?.allHeaderFields as? [String : String]
            self.url = response.response?.url
            self.data = response.data
        }
    }
    
    // URL string used on the call
    public var url : String
    
    /* Parameters to be used on the call.
     * On POST and PUT calls this represents the Body.
     * On GET calls this will be encoded on the URL and must be on [String:String] format. */
    public var parameters : [String:Any]
    
    // Header used on the call
    public var headers : [String:String]
    
    //How the parameters are attatched to the request. Default is methodDependent
    //GET + DELETE: urlEncoded
    //POST + PUT: json on body
    public var parametersEncoding : URLEncoding.Destination = .methodDependent
    
    
    public var request : Request?
    let sessionManager = Alamofire.SessionManager.default
    
    
    public init (url : String, parameters : [String:Any] = [:], headers : [String:String] = [:]) {
        // Converts to urlQueryAllowed just in case
        self.url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        self.parameters = parameters
        self.headers = headers
        self.request = nil
        
        self.sessionManager.startRequestsImmediately = false
    }
    
    
    /** Starts a POST connection on the given Path **/
    public func post(path : String, handler : @escaping (Bool, HTTPResponse) -> Void) {
        self.startRESTRequest(url: self.url + path,
                              method: .post,
                              handler: handler)
    }
    
    /** Starts a PUT connection on the given Path **/
    public func put(path : String, handler : @escaping (Bool, HTTPResponse) -> Void) {
        self.startRESTRequest(url: self.url + path,
                              method: .put,
                              handler: handler)
    }
    
    /** Starts a GET connection on the given Path **/
    public func get(path : String, handler : @escaping (Bool, HTTPResponse) -> Void) {
        self.startRESTRequest(url: self.url + path,
                              method: .get,
                              handler: handler)
    }
    
    /** Starts a DELETE connection on the given Path **/
    public func delete(path : String, handler : @escaping (Bool, HTTPResponse) -> Void) {
        self.startRESTRequest(url: self.url + path,
                              method: .delete,
                              handler: handler)
    }
    
    /** Cancels the current request **/
    public func cancelRequest() {
        self.request?.cancel()
    }
    
    /** Downloads a file on the given path **/
    public func download(path : String, progressHandler : ((Double) -> Void)?, handler : @escaping (Bool, HTTPResponse) -> Void) {
        self.startDownloadRequest(url: self.url + path,
                                  progressHandler: progressHandler,
                                  handler: handler)
    }
    
    
    private func startRESTRequest(url: String, method : HTTPMethod, handler : @escaping (Bool, HTTPResponse) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        self.request = Alamofire.request(url,
                                         method: method,
                                         parameters: method == .get || method == .delete ? self.parameters as! [String:String] : self.parameters,
                                         encoding: URLEncoding(destination: .methodDependent),
                                         headers: self.headers).validate().responseJSON { response in
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                            
                                            self.request = nil
                                            
                                            let httpResponse = HTTPResponse(response: response)
                                            
                                            handler(response.result.isSuccess, httpResponse)
        }
        
        self.request?.resume()
    }
    
    private func startDownloadRequest(url: String, progressHandler : ((Double) -> Void)?, handler : @escaping (Bool, HTTPResponse) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        self.request = Alamofire.request(url,
                                         method: .get,
                                         parameters: self.parameters as! [String:String],
                                         encoding: URLEncoding(destination: .methodDependent),
                                         headers: self.headers).downloadProgress { progress in
                                            progressHandler?(progress.fractionCompleted)
            }.validate().responseData { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                self.request = nil
                
                let httpResponse = HTTPResponse(response: response)
                
                handler(response.result.isSuccess, httpResponse)
        }
        
        self.request?.resume()
    }
}

