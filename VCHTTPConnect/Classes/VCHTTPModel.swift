//
//  HTTPModel.swift
//  GameCalendar
//
//  Created by Vitor Cesco on 29/05/17.
//  Copyright © 2017 Vitor Cesco. All rights reserved.
//

import UIKit
import ObjectMapper

open class VCHTTPModel: VCEntityModel {
    
    /** Connector used on HTTP Requests */
    public var connector: VCHTTPConnect?
    
    required public init?(map: Map) {
        super.init(map: map)
        self.initializeConnector()
    }
    
    // MARK: - Overridable
    
    /** Initialize the connector with the desired settings */
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
}
