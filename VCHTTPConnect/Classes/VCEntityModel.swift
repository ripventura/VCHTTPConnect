//
//  VCEntityModel.swift
//  Pods
//
//  Created by Vitor Cesco on 29/06/17.
//
//

import Foundation
import ObjectMapper
import VCSwiftToolkit

open class VCEntityModel: Mappable {
    
    /** This model unique Id */
    public var modelId: String?
    
    // MARK: - ObjectMapper
    
    public required init?(map: Map) {
        
    }
    
    open func mapping(map: Map) {
        self.modelId <- map["id"]
    }
}
