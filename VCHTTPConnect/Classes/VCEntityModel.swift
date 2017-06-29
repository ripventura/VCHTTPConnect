//
//  VCEntityModel.swift
//  Pods
//
//  Created by Vitor Cesco on 29/06/17.
//
//

import Foundation
import ObjectMapper

open class VCEntityModel: Mappable {
    
    /* This model Id */
    public var modelId: Any?
    
    /* Connector used on HTTP Requests */
    public var connector: VCHTTPConnect?
    
    // MARK: - ObjectMapper
    
    required public init?(map: Map) {
        self.initializeConnector()
    }
    
    // MARK: - Overridable
    
    /** Initialize the connector with the desired settings */
    open func initializeConnector() -> Void {
        
    }
    
    // Mappable
    open func mapping(map: Map) {
        self.modelId <- map["id"]
    }
}
