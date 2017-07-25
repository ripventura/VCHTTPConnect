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

/** Mappable Model with built-in persistable function. */
open class VCPersistableModel: Mappable {
    
    // MARK: - ObjectMapper
    
    public required init?(map: Map) {
        
    }
    
    open func mapping(map: Map) {
        
    }
    
    // MARK: - Persistable
    
    /** Persists this model locally using the given unique Key string. */
    open func persist(key: String) -> VCOperationResult {
        return sharedCacheManager.cache(type: .json, content: self.toJSON(), key: key)
    }
}

/** VCPersistableModel holding a modelId as unique identifier. */
open class VCEntityModel: VCPersistableModel {
    
    /* This model unique Id */
    public var modelId: String?
    
    // MARK: - ObjectMapper

    open override func mapping(map: Map) {
        self.modelId <- map["id"]
    }
    
    // MARK: - Persistable
    
    /** Persists this model locally using the modelId as Key string. */
    open func persist() -> VCOperationResult {
        if let key = self.modelId {
            return self.persist(key: key)
        }
        else {
            return VCOperationResult(success: false, error: nil)
        }
    }
}
