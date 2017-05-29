//
//  VCHTTPConnect.swift
//  TimeClockBadge
//
//  Created by Vitor Cesco on 8/25/16.
//  Copyright © 2016 Rolfson Oil. All rights reserved.
//

import Foundation
import SwiftHTTP

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
    }
    
    // URL string used on the call
    public var url : String
    
    /* Parameters to be used on the call. 
     * On POST and PUT calls this represents the Body.
     * On GET calls this will be encoded on the URL. */
    public var parameters : [String:Any]
    
    // Header used on the call
    public var headers : [String:String]
    
    
    private var request : HTTP?
    
    private var shouldHandleRequest : Bool
    
    
    public init (url : String, parameters : [String:Any] = [:], headers : [String:String] = [:]) {
        // Converts to urlQueryAllowed just in case
        self.url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        self.parameters = parameters
        self.headers = headers
        self.request = nil
        self.shouldHandleRequest = true
    }
    
    
    /** Starts a POST connection on the given Path **/
    public func post(path : String, handler : @escaping (Bool, HTTPResponse) -> Void) {
        do {
            let opt = try HTTP.POST(self.url + path, parameters: self.getParameters(), headers: self.getHeaders())
            
            self.startRequest(opt: opt, handler: handler)
        }
        catch let error {
            debugPrint("[VCHTTPConnect] Error creating request: \(error)")
            
            self.request = nil
            
            DispatchQueue.main.async {
                handler(false, HTTPResponse(statusCode: nil, error: error, headers: nil, url: nil, data: nil))
            }
        }
    }
    
    /** Starts a PUT connection on the given Path **/
    public func put(path : String, handler : @escaping (Bool, HTTPResponse) -> Void) {
        do {
            let opt = try HTTP.PUT(self.url + path, parameters: self.getParameters(), headers: self.getHeaders())
            
            self.startRequest(opt: opt, handler: handler)
        }
        catch let error {
            debugPrint("[VCHTTPConnect] Error creating request: \(error)")
            
            self.request = nil
            
            DispatchQueue.main.async {
                handler(false, HTTPResponse(statusCode: nil, error: error, headers: nil, url: nil, data: nil))
            }
        }
    }
    
    /** Starts a GET connection on the given Path **/
    public func get(path : String, handler : @escaping (Bool, HTTPResponse) -> Void) {
        do {
            let opt = try HTTP.GET(self.url + path, parameters: self.getParameters(), headers: self.getHeaders())
            
            self.startRequest(opt: opt, handler: handler)
        }
        catch let error {
            debugPrint("[VCHTTPConnect] Error creating request: \(error)")
            
            self.request = nil
            
            DispatchQueue.main.async {
                handler(false, HTTPResponse(statusCode: nil, error: error, headers: nil, url: nil, data: nil))
            }
        }
    }
    
    /** Starts a DELETE connection on the given Path **/
    public func delete(path : String, handler : @escaping (Bool, HTTPResponse) -> Void) {
        do {
            let opt = try HTTP.DELETE(self.url + path, parameters: self.getParameters(), headers: self.getHeaders())
            
            self.startRequest(opt: opt, handler: handler)
        }
        catch let error {
            debugPrint("[VCHTTPConnect] Error creating request: \(error)")
            
            self.request = nil
            
            DispatchQueue.main.async {
                handler(false, HTTPResponse(statusCode: nil, error: error, headers: nil, url: nil, data: nil))
            }
        }
    }
    
    /** Cancels the current request **/
    public func cancelRequest() {
        self.shouldHandleRequest = false
        self.request?.cancel()
    }
    
    
    private func startRequest(opt : HTTP, handler : @escaping (Bool, HTTPResponse) -> Void) {
        self.request = opt
        
        opt.start { response in
            //do things...
            
            self.request = nil
            
            if self.shouldHandleRequest {
                DispatchQueue.main.async {
                    handler(
                        (response.statusCode != nil && response.statusCode! >= 200 && response.statusCode! <= 299),
                        HTTPResponse(statusCode: response.statusCode, error: response.error, headers: response.headers, url: response.URL, data: response.data))
                }
            }
            else {
                self.shouldHandleRequest = true
            }
        }
    }
    
    
    /** Override this if you want to use predefined values on a sub-class **/
    internal func getParameters() -> [String:Any]{
        return self.parameters
    }
    /** Override this if you want to use predefined values on a sub-class **/
    internal func getHeaders() -> [String:String]{
        return self.headers
    }
    
}
