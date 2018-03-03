//
//  VCHTTPConnect.swift
//  TimeClockBadge
//
//  Created by Vitor Cesco on 8/25/16.
//  Copyright © 2016 Rolfson Oil. All rights reserved.
//

import Foundation
import Alamofire

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
        // Description of the HTTP call
        public let description: String?
        
        /** Initializes this HTTPResponse with an Alamofire Response object. */
        public init(response: DataResponse<Data>) {
            self.statusCode = response.response?.statusCode
            self.error = response.error
            self.headers = response.response?.allHeaderFields as? [String : String]
            self.url = response.response?.url
            self.data = response.data
            self.description = response.description
        }
        public init(response: DataResponse<Any>) {
            self.statusCode = response.response?.statusCode
            self.error = response.error
            self.headers = response.response?.allHeaderFields as? [String : String]
            self.url = response.response?.url
            self.data = response.data
            self.description = response.description
        }
    }
    
    // URL string used on the call
    public var url : String
    
    /** Parameters to be used on the request. */
    public var parameters : [String:Any]
    
    /** HTTP Headers used on the request. */
    public var headers : [String:String]
    
    /** How the parameters are attatched to the request. Default is methodDependent.
     Default config:
     POST + PUT: json on body.
     GET + DELETE: urlEncoded encoded on the URL and must be on [String:String] format. */
    public var parametersEncoding : URLEncoding.Destination = .methodDependent
    
    /** Wheter the last request was canceled by the user. */
    public var canceledRequest: Bool = false
    
    /** The request object. */
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
    
    
    /** Starts a POST connection on the given Path */
    public func post(path : String, handler : @escaping (Bool, HTTPResponse) -> Void) {
        self.startRESTRequest(url: self.url + path,
                              method: .post,
                              handler: handler)
    }
    
    /** Starts a PUT connection on the given Path */
    public func put(path : String, handler : @escaping (Bool, HTTPResponse) -> Void) {
        self.startRESTRequest(url: self.url + path,
                              method: .put,
                              handler: handler)
    }
    
    /** Starts a GET connection on the given Path */
    public func get(path : String, handler : @escaping (Bool, HTTPResponse) -> Void) {
        self.startRESTRequest(url: self.url + path,
                              method: .get,
                              handler: handler)
    }
    
    /** Starts a DELETE connection on the given Path */
    public func delete(path : String, handler : @escaping (Bool, HTTPResponse) -> Void) {
        self.startRESTRequest(url: self.url + path,
                              method: .delete,
                              handler: handler)
    }
    
    /** Cancels the current request **/
    public func cancelRequest() {
        self.canceledRequest = true
        self.request?.cancel()
    }
    
    /** Downloads a file on the given path */
    public func download(path : String, progressHandler : ((Double) -> Void)?, handler : @escaping (Bool, HTTPResponse) -> Void) {
        self.startDownloadRequest(url: self.url + path,
                                  progressHandler: progressHandler,
                                  handler: handler)
    }
    
    
    private func startRESTRequest(url: String, method : HTTPMethod, handler : @escaping (Bool, HTTPResponse) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        func handleResponse(response: DataResponse<Any>) {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            self.request = nil
            
            let httpResponse = HTTPResponse(response: response)
            
            handler(response.result.isSuccess, httpResponse)
        }
        
        if method == .get || method == .delete {
            self.request = Alamofire.request(url,
                                             method: method,
                                             parameters: self.parameters as! [String:String],
                                             encoding: URLEncoding(destination: .methodDependent),
                                             headers: self.headers).validate().debugLog().responseJSON { response in
                                                handleResponse(response: response)
            }
        }
        else {
            self.request = Alamofire.request(url,
                                             method: method,
                                             parameters: self.parameters,
                                             encoding: JSONEncoding(options: .prettyPrinted),
                                             headers: self.headers).validate().debugLog().responseJSON {response in
                                                handleResponse(response: response)
            }
        }
        self.canceledRequest = false
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
        self.canceledRequest = false
        self.request?.resume()
    }
}

extension Request {
    public func debugLog() -> Self {
        #if DEBUG
            debugPrint("=======================================")
            debugPrint(self)
            debugPrint("=======================================")
        #endif
        return self
    }
}
