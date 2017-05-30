//
//  VCHTTPDatastore.swift
//  Pods
//
//  Created by Vitor Cesco on 30/05/17.
//
//

import UIKit

open class VCHTTPDatastore: NSObject {
    
    /* Connector used on HTTP Requests */
    public var connector: VCHTTPConnect?
    
    /* The name of the Datastore */
    public var name: String?
    /* The URL of the Datastore */
    public var url: String?
    
    
    /* Use this initalizer if you are not initializing to a custom datastore. */
    public init(name: String, url: String) {
        self.name = name
        self.url = url
        
        super.init()
    }
    
    /* Use this initalizer if you are initializing a custom datastore. */
    public override init() {
        
    }
    
    
    //Finds entity with the given filter
    open func find(filter: [String:Any], completionHandler: @escaping((VCHTTPConnect.HTTPResponse, [VCHTTPModel]?) -> Void)) -> Void {
        self.connector = VCHTTPConnect(url: self.url != nil ? self.url! : self.datastoreURL())
        self.connector?.parameters = filter
        self.connector?.get(path: "/" + (self.name != nil ? self.name! : self.datastoreName()), handler: {success, response in
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
    
    
    //Override this if you sub-class to a custom datastore.
    open func datastoreName() -> String {
        return ""
    }
    //Override this if you sub-class to a custom datastore.
    open func datastoreURL() -> String {
        return ""
    }
    //Override this if you need to return custom sub-classed models.
    open func modelFromDict(jsonDict: [String:Any]) -> VCHTTPModel {
        return VCHTTPModel(JSON: jsonDict)!
    }
}
