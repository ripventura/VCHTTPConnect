//
//  VCGraphQLDatastore.swift
//  Pods
//
//  Created by Vitor Cesco on 22/06/17.
//
//

import UIKit

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
    
    // MARK: - Overridable
    
    /** Use this initalizer if you are initializing a custom datastore. */
    public override init() {
        
    }
    
    /** Default Model initialization. */
    open func modelFromDict(jsonDict: [String:Any]) -> VCGraphQLModel {
        return VCGraphQLModel(JSON: jsonDict)!
    }
    
    // MARK: - Query
    
    /** Queries the Datastore with the given Query and Variables. */
    open func query(query: String,
                    variables: [String:Any]?,
                    completionHandler: @escaping((VCHTTPConnect.HTTPResponse, [String:Any]?) -> Void)) -> Void {
        
        self.setupConnector(query: query, variables: variables)
        self.connector?.post(path: "", handler: {success, response in
            var dataDict: [String:Any]?
            
            if success {
                do {
                    let jsonObject: [String:Any]? = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any]
                    
                    dataDict = jsonObject?["data"] as? [String:Any]
                }
                catch {
                }
            }
            
            return completionHandler(response, dataDict)
        })
    }
    
    // MARK: - Mutation
    
    /** Performs a Mutation on the Datastore with the given Query and Variables */
    open func mutation(query: String,
                    variables: [String:Any]?,
                    completionHandler: @escaping((VCHTTPConnect.HTTPResponse, [String:Any]?) -> Void)) -> Void {
        
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
