//
//  VCDatabase.swift
//  Pods
//
//  Created by Vitor Cesco on 26/07/17.
//
//

import UIKit
import VCSwiftToolkit
import ObjectMapper

open class VCDatabase {
    open class Metadata: Mappable {
        open var referenceDate: Date?
        
        public required init?(map: Map) {
            
        }
        
        public func mapping(map: Map) {
            self.referenceDate <- (map["referenceDate"], ISO8601DateTransform())
        }
    }
    
    private let databaseFolderName: String = "VCDatabase"
    
    open var name: String
    open var metadata: Metadata = Metadata(JSON: [:])!
    internal var models: [VCEntityModel] = []
    
    public init(name: String) {
        self.name = name
        
        self.reset()
        
        self.prepareStructure()
    }
    
    /** Sub class this to initialize the desired VCEntityModel. */
    open func modelInit(entity: String) -> VCEntityModel? {
        return VCEntityModel(JSONString: entity)
    }
    
    /** Commits this Database content to local storage. */
    open func commit() -> VCOperationResult {
        return self.save()
    }
    
    // MARK: - INSERT
    
    /** Inserts a model on a given Table. */
    open func insert(model: VCEntityModel) {
        return self.batchInsert(models: [model])
    }
    
    /** Batch Inserts an Array of models on a given Table. */
    open func batchInsert(models: [VCEntityModel]) {
        self.models.append(contentsOf: models)
    }
    
    // MARK: - UPDATE
    
    /** Updates a model on a given Table. */
    open func update(model: VCEntityModel) {
        return self.batchUpdate(models: [model])
    }
    
    /** Batch Updates an Array of models on a given Table. */
    open func batchUpdate(models: [VCEntityModel]) {
        // Loads the Table models
        var tableModels: [VCEntityModel] = self.models
        
        // Loops each model to update
        for model in models {
            // Loops every model on the Table
            for (index, tableModel) in tableModels.enumerated() {
                // If they are the same
                if model.modelId != nil && model.modelId == tableModel.modelId {
                    // Replace
                    tableModels[index] = model
                }
            }
        }
        
        self.models = tableModels
    }
    
    // MARK: - SELECT
    
    /** Selects models. */
    open func select(filter: ((VCEntityModel) -> Bool) = {_ in return true}) -> [VCEntityModel] {
        return self.models.filter({model in
            return filter(model)
        })
    }
    
    /** Selects a model by modelId. */
    open func select(modelId: String) -> VCEntityModel? {
        return self.select(filter: {model in return model.modelId == modelId}).first
    }
    
    // MARK: - DELETE
    
    /** Deletes a model by ID. */
    open func delete(modelId: String) {
        return self.batchDelete(condition: {model in return model.modelId == modelId})
    }
    
    /** Batch Delete models. */
    open func batchDelete(condition: ((VCEntityModel) -> Bool)) {
        self.models = self.models.filter({model in return !condition(model)})
    }
    
    // MARK: - RESET
    
    /** Resets this Database, reloading data from local storage. */
    open func reset() {
        self.clear()
        
        let info = self.load()
        self.metadata = info.metadata
        self.models = info.models
    }
    
    // MARK: - REPLACE
    
    /** Replaces ALL the models with the new ones. */
    open func replace(models: [VCEntityModel]) {
        self.models = models
    }
    
    // MARK: - CLEAR
    
    /** Clears the Database content, deleting ALL models. */
    open func clear() {
        self.models = []
    }
    
    // MARK: - Internal
    
    /** Saves an array of models on the Table file */
    internal func save() -> VCOperationResult {
        return VCFileManager.writeDictionary(dictionary: [
            "metadata": self.metadata.toJSONString()!,
            "entities": self.models.toJSONString() ?? []
            ],
                                             fileName: self.name,
                                             fileExtension: "plist",
                                             directory: .library,
                                             customFolder: self.databaseFolderName,
                                             replaceExisting: true)
    }
    
    /** Loads all the entities + metadata from a Table */
    internal func load() -> (models: [VCEntityModel], metadata: Metadata) {
        // Loads the Table
        let tableDict: [String:Any] = self.loadRaw()
        
        let entities: [String] = tableDict["entities"] as! [String]
        
        // Converts entities to models
        var models: [VCEntityModel] = []
        for entity in entities {
            if let model = self.modelInit(entity: entity) {
                models.append(model)
            }
        }
        
        return (models, Metadata(JSON: tableDict["metadata"] as! [String:Any])!)
    }
    
    // MARK: - Fileprivate 
    
    fileprivate func prepareStructure() -> Void {
        _ = VCFileManager.createFolderInDirectory(directory: .library,
                                                  folderName: self.databaseFolderName)
    }
    
    /** Loads the raw Table dictionary */
    fileprivate func loadRaw() -> [String:Any] {
        if let table = VCFileManager.readDictionary(fileName: self.name,
                                                    fileExtension: "plist",
                                                    directory: .library,
                                                    customFolder: self.databaseFolderName) {
            return table as! [String:Any]
        }
        return [:]
    }
}
