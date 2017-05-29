//
//  HTTPModel.swift
//  GameCalendar
//
//  Created by Vitor Cesco on 29/05/17.
//  Copyright © 2017 Vitor Cesco. All rights reserved.
//

import UIKit

open class HTTPModel: JSONModel {

    //VCHTTPConnect connector used on HTTP Requests
    public var connector: VCHTTPConnect?
    
    public override init() {
        super.init()
        
        self.initializeConnector()
    }
    public override init(jsonDict: [String : Any]) {
        super.init(jsonDict: jsonDict)
        
        self.initializeConnector()
    }
    
    //Connector should be initialized here. Override this method on each subclass.
    open func initializeConnector() -> Void {
        
    }

    //Creates an entity based on this model
    public func create(completionHandler: @escaping ((Bool, VCHTTPConnect.HTTPResponse) -> Void)) -> Void {
        if let connector = self.connector {
            connector.parameters = self.jsonDict()
            connector.post(path: "", handler: completionHandler)
            
        } else {
            assert(true, "Connector not initialized!")
        }
    }
    //Updates an entity based on this model
    public func update(completionHandler: @escaping ((Bool, VCHTTPConnect.HTTPResponse) -> Void)) -> Void {
        if let connector = self.connector {
            connector.parameters = self.jsonDict()
            connector.put(path: "", handler: completionHandler)
            
        } else {
            assert(true, "Connector not initialized!")
        }
    }
    //Removes an entity based on this model ID
    public func remove(completionHandler: @escaping ((Bool, VCHTTPConnect.HTTPResponse) -> Void)) -> Void {
        if let connector = self.connector {
            if let modelId = self.modelId {
                
                connector.delete(path: "/"+String(describing: modelId), handler: completionHandler)
            } else {
                assert(true, "ModelId not set!")
            }
            
        } else {
            assert(true, "Connector not initialized!")
        }
    }
}
