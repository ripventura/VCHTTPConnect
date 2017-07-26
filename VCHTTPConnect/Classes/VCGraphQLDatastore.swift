//
//  VCGraphQLDatastore.swift
//  Pods
//
//  Created by Vitor Cesco on 22/06/17.
//
//

import UIKit
import VCSwiftToolkit

/** Shared GraphQL settings used on GraphQL calls.
 Update this everytime it's needed (after Auth, for exemple). */
public var sharedGraphQLConfig = VCGraphQLConfig(host: "", headers: [:])

open class VCGraphQLConfig: NSObject {
    open var host: String
    open var headers: [String:String]
    
    public init(host: String, headers: [String:String]) {
        self.host = host
        self.headers = headers
    }
}

open class VCGraphQLDatastore: NSObject {
    /** Connector used on HTTP Requests */
    public var connector: VCHTTPConnect?
    
    /** Wheter or not data should be cached after a successfull connection.
     CacheKey is also need for caching to occur.
     */
    public var isCachingEnabled: Bool = true
    
    // MARK: - Overridable
    
    /** Use this initalizer if you are initializing a custom datastore. */
    public override init() {
        
    }
    
    // MARK: - Query
    
    /** Queries the Datastore with the given Query and Variables.
     - Parameters:
     - query: The Query to be made.
     - variables: Optional dictionary of variables for this Query.
     - cacheKey: A optional Key to be used to store this Query's reponse (in case of success).
     */
    open func query(query: String,
                    variables: [String:Any]?,
                    cacheKey: String? = nil,
                    completionHandler: @escaping((VCHTTPConnect.HTTPResponse?, [String:Any]?) -> Void)) -> Void {
        
        // If the ConnectionManager is in Online mode
        if sharedConnectionManager.state == .online {
            self.setupConnector(query: query, variables: variables)
            
            self.connector?.post(path: "", handler: {success, response in
                var dataDict: [String:Any]?
                
                if success {
                    dataDict = (response.data?.vcAnyFromJSON() as? [String:Any])?["data"] as? [String:Any]
                    
                    // If this Datastore is set to cache data and a Key was provided
                    if self.isCachingEnabled && cacheKey != nil {
                        // Caches data (overriding any existing content)
                        print("Cache for " + cacheKey! + ":", sharedCacheManager.cache(type: .json, content: dataDict as Any, key: cacheKey!).success)
                    }
                }
                
                return completionHandler(response, dataDict)
            })
        }
            // If the ConnectionManager is in Offline mode
        else {
            // Returns any stored cached version
            return cacheKey != nil ?
                completionHandler(nil, sharedCacheManager.retrieve(type: .json, key: cacheKey!) as? [String:Any]) :
                completionHandler(nil, nil)
        }
    }
    
    // MARK: - Mutation
    
    /** Performs a Mutation on the Datastore with the given Query and Variables.
     Mutations cannot be cached.
     - Parameters:
     - query: The Query to be made.
     - variables: Optional dictionary of variables for this Query.
     */
    open func mutation(query: String,
                       variables: [String:Any]?,
                       completionHandler: @escaping((VCHTTPConnect.HTTPResponse?, [String:Any]?) -> Void)) -> Void {
        self.query(query: query,
                   variables: variables,
                   cacheKey: nil,
                   completionHandler: completionHandler)
    }
    
    // MARK: - Helpers
    
    internal func setupConnector(query: String, variables: [String:Any]?) -> Void {
        var params : [String:Any] = ["query":query]
        if let variables = variables {
            params["variables"] = variables
        }
        
        self.connector = VCHTTPConnect(url: sharedGraphQLConfig.host)
        self.connector?.parameters = params
        self.connector?.headers = sharedGraphQLConfig.headers
    }
}
