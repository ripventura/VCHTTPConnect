//
//  VCGraphQLDatastore.swift
//  Pods
//
//  Created by Vitor Cesco on 22/06/17.
//
//

import UIKit

open class VCGraphQLDatastore: NSObject {
    public struct Config {
        let url: String
        let headers: [String:String]
        
        public init(url: String, headers: [String:String]) {
            self.url = url
            self.headers = headers
        }
    }
    
    /** Connector used on HTTP Requests */
    public var connector: VCHTTPConnect?
    
    
    /** Use this initalizer if you are initializing a custom datastore. */
    public override init() {
        
    }
    
    /** Returns the config used on this datastore. Override this! */
    open func datastoreWithConfig() -> VCGraphQLDatastore.Config {
        return .init(url: "", headers: [:])
    }
    /** Override this if you need to return custom sub-classed models. */
    open func modelFromDict(jsonDict: [String:Any]) -> VCHTTPModel {
        return VCHTTPModel(JSON: jsonDict)!
    }
    
    /** Queries the Datastore with the given Query and Variables */
    open func query(query: [String:Any],
                    variables: [String:Any]?,
                   completionHandler: @escaping((VCHTTPConnect.HTTPResponse, [VCHTTPModel]?) -> Void)) -> Void {
        let config = self.datastoreWithConfig()
        
        var params : [String:Any] = ["query":query]
        if let variables = variables {
            params["variables"] = variables
        }
        
        self.connector = VCHTTPConnect(url: config.url)
        self.connector?.parameters = params
        self.connector?.headers = config.headers
        self.connector?.post(path: "", handler: {success, response in
            if success {
                do {
                    let jsonObject: [[String:Any]]? = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String:Any]]
                    
                    if let jsonArray = jsonObject {
                        var models: [VCHTTPModel] = []
                        
                        for modelDict in jsonArray {
                            models.append(self.modelFromDict(jsonDict: modelDict))
                        }
                        
                        completionHandler(response, models)
                    }
                }
                catch {
                    return completionHandler(response, nil)
                }
            } else {
                return completionHandler(response, nil)
            }
        })
    }
}
