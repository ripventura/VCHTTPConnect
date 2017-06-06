//
//  VCHTTPDatastore.swift
//  Pods
//
//  Created by Vitor Cesco on 30/05/17.
//
//

import UIKit

open class VCHTTPDatastore: NSObject {
    public struct Config {
        let name: String
        let url: String
        let header: [String:String]
        
        public init(name: String, url: String, header: [String:String]) {
            self.name = name
            self.url = url
            self.header = header
        }
    }
    
    /* Connector used on HTTP Requests */
    public var connector: VCHTTPConnect?

    
    /* Use this initalizer if you are initializing a custom datastore. */
    public override init() {
        
    }
    
    
    //Finds entity with the given filter
    open func find(filter: [String:Any], completionHandler: @escaping((VCHTTPConnect.HTTPResponse, [VCHTTPModel]?) -> Void)) -> Void {
        let config = self.datastoreWithConfig()
        self.connector = VCHTTPConnect(url: config.url)
        self.connector?.parameters = filter
        self.connector?.headers = config.header
        self.connector?.get(path: "/" + config.name, handler: {success, response in
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
    
    //Returns the config used on this datastore
    open func datastoreWithConfig() -> VCHTTPDatastore.Config {
        return .init(name: "", url: "", header: [:])
    }
    //Override this if you need to return custom sub-classed models.
    open func modelFromDict(jsonDict: [String:Any]) -> VCHTTPModel {
        return VCHTTPModel(JSON: jsonDict)!
    }
}
