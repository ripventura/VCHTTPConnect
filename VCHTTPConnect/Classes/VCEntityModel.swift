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
    
    required public init?(map: Map) {
        
    }
    
    // Mappable
    open func mapping(map: Map) {
        self.modelId <- map["id"]
    }
}
