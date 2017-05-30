//
//  HTTPModel.swift
//  GameCalendar
//
//  Created by Vitor Cesco on 29/05/17.
//  Copyright © 2017 Vitor Cesco. All rights reserved.
//

import UIKit
import ObjectMapper

open class VCHTTPModel: Mappable {

    /* This model Id */
    public var modelId: Any?
    
    /* Connector used on HTTP Requests */
    public var connector: VCHTTPConnect?
    
    
    //Connector should be initialized here. Override this method on each subclass.
    open func initializeConnector() -> Void {
        
    }

    
    // MARK: - Operations
    
    //Creates an entity based on this model
    open func create(completionHandler: @escaping ((Bool, VCHTTPConnect.HTTPResponse) -> Void)) -> Void {
        if let connector = self.connector {
            connector.parameters = self.toJSON()
            connector.post(path: "", handler: completionHandler)
            
        } else {
            assert(true, "Connector not initialized!")
        }
    }
    //Updates an entity based on this model
    open func update(completionHandler: @escaping ((Bool, VCHTTPConnect.HTTPResponse) -> Void)) -> Void {
        if let connector = self.connector {
            connector.parameters = self.toJSON()
            connector.put(path: "", handler: completionHandler)
            
        } else {
            assert(true, "Connector not initialized!")
        }
    }
    //Removes an entity based on this model ID
    open func remove(completionHandler: @escaping ((Bool, VCHTTPConnect.HTTPResponse) -> Void)) -> Void {
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
    
    
    // MARK: - ObjectMapper
    required public init?(map: Map) {
        self.initializeConnector()
    }
    
    // Mappable
    open func mapping(map: Map) {
        self.modelId <- map["id"]
    }
}
