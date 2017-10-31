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

open class VCGraphQLConnector: NSObject {
    /** Connector used on HTTP Requests */
    public var connector: VCHTTPConnect?
    
    // MARK: - Overridable
    
    /** Use this initalizer if you are initializing a custom datastore. */
    public override init() {
        
    }
    
    // MARK: - Query
    
    /** Queries the Datastore with the given Query and Variables.
     - Parameters:
     - query: The Query to be made.
     - variables: Optional dictionary of variables for this Query.
     */
    open func query(query: String,
                    variables: [String:Any]?,
                    completionHandler: @escaping((VCHTTPConnect.HTTPResponse?, [String:Any]?) -> Void)) -> Void {
        
        self.setupConnector(query: query, variables: variables)
        
        self.connector?.post(path: "", handler: {success, response in
            var dataDict: [String:Any]?
            
            if success {
                dataDict = (response.data?.vcAnyFromJSON() as? [String:Any])?["data"] as? [String:Any]
            }
            
            return completionHandler(response, dataDict)
        })
    }
    
    // MARK: - Mutation
    
    /** Performs a Mutation on the Datastore with the given Query and Variables.
     - Parameters:
     - query: The Query to be made.
     - variables: Optional dictionary of variables for this Query.
     */
    open func mutation(query: String,
                       variables: [String:Any]?,
                       completionHandler: @escaping((VCHTTPConnect.HTTPResponse?, [String:Any]?) -> Void)) -> Void {
        self.query(query: query,
                   variables: variables,
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

