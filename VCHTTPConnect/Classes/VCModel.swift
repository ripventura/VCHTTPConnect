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
    /** Wheter or not this Model should be persistable */
    public var persistable: Bool = false
    
    /** This model unique Id */
    public var modelId: String?
    
    // MARK: - ObjectMapper
    
    public required init?(map: Map) {
        
    }
    
    open func mapping(map: Map) {
        self.modelId <- map["id"]
    }
    
    // MARK: - Persistable
    
    /** Persists the Model on the local Database */
    open func persist() -> VCOperationResult {
        return sharedDatabase.insert(model: self, table: VCDatabase.Table(name: String(describing: self), key: nil))
    }
}
