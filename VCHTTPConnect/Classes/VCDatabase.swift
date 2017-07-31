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

public let sharedDatabase: VCDatabase = VCDatabase()

open class VCDatabase {
    open class Table {
        /** An unique key to identify this Table */
        public var key: String
        
        public init(key: String) {
            self.key = key
        }
    }
    open class ParserTable: Table {
        /** Initializer used to parse JSON string to model */
        public var initializer: ((String) -> VCEntityModel?)
        
        public init(key: String, initializer: @escaping ((String) -> VCEntityModel?)) {
            self.initializer = initializer
            super.init(key: key)
        }
    }
    
    let databaseName: String = "VCDatabase"
    
    public init() {
        self.prepareStructure()
    }
    
    // MARK: - INSERT
    
    /** Inserts a model on a given Table. */
    open func insert(model: VCEntityModel,
                     table: Table) -> VCOperationResult {
        
        return self.batchInsert(models: [model], table: table)
    }
    
    /** Batch Inserts an Array of models on a given Table. */
    open func batchInsert(models: [VCEntityModel],
                          table: Table) -> VCOperationResult {
        // Loads the Table
        var entities: [String] = self.retrieve(table: table)
        
        // Appends the new entities
        for model in models {
            if let jsonString = model.toJSONString() {
                entities.append(jsonString)
            }
        }
        
        // Saves the Table
        return self.save(table: table, entities: entities as NSArray)
    }
    
    // MARK: - UPDATE
    
    /** Updates a model on a given Table. */
    open func update(model: VCEntityModel,
                     table: ParserTable) -> VCOperationResult {
        
        return self.batchUpdate(models: [model], table: table)
    }
    
    /** Batch Updates an Array of models on a given Table. */
    open func batchUpdate(models: [VCEntityModel],
                          table: ParserTable) -> VCOperationResult {
        // Loads the Table models
        var tableModels: [VCEntityModel] = self.retrieve(table: table)
        
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
        
        // Saves the Table
        return self.save(table: table, models: tableModels)
    }
    
    // MARK: - REPLACE
    
    /** Replaces a given Table content with the new models. */
    open func replace(models: [VCEntityModel],
                      table: Table) -> VCOperationResult {
        _ = self.delete(table: table)
        
        return self.batchInsert(models: models, table: table)
    }
    
    // MARK: - SELECT
    
    /** Selects models from a given Table. */
    open func select(table: ParserTable,
                     filter: ((VCEntityModel) -> Bool) = {_ in return true}) -> [VCEntityModel] {
        // Loads the Table models
        var models: [VCEntityModel] = self.retrieve(table: table)
        
        // Filters all the models
        models = models.filter({model in
            return filter(model)
        })
        
        return models
    }
    
    /** Selects a model by modelId from a given Table. */
    open func select(modelId: String,
                     table: ParserTable) -> VCEntityModel? {
        // Loads the Table models
        var models: [VCEntityModel] = self.retrieve(table: table)
        
        // Filters all the models
        models = models.filter({model in
            return model.modelId == modelId
        })
        
        return models.first
    }
    
    // MARK: - DELETE
    
    /** Deletes a model by ID on a given Table. */
    open func delete(modelId: String,
                     table: ParserTable) -> VCOperationResult {
        return self.batchDelete(condition: {model in return model.modelId == modelId}, table: table)
    }
    
    /** Batch Deletes models on a given Table. */
    open func batchDelete(condition: ((VCEntityModel) -> Bool),
                          table: ParserTable) -> VCOperationResult {
        var newEntities: [String] = []
        let models: [VCEntityModel] = self.retrieve(table: table)
        
        // Loads all the Models
        for model in models {
            // If this Model should be kept
            if !condition(model) {
                // Keep it
                if let jsonString = model.toJSONString() {
                    newEntities.append(jsonString)
                }
            }
        }
        
        // Save the Table
        return self.save(table: table, entities: newEntities as NSArray)
    }
    
    /** Deletes a given Table. */
    open func delete(table: Table) -> VCOperationResult {
        return VCFileManager.deleteFile(fileName: table.key,
                                        fileExtension: "plist",
                                        directory: .library,
                                        customFolder: self.databaseName)
    }
    
    // MARK: - Internal
    
    internal func prepareStructure() -> Void {
        _ = VCFileManager.createFolderInDirectory(directory: .library,
                                                  folderName: self.databaseName)
    }
    
    /** Saves an array of entities (String format) on the Table file */
    internal func save(table: Table, entities: NSArray) -> VCOperationResult {
        return VCFileManager.writeArray(array: entities,
                                        fileName: table.key,
                                        fileExtension: "plist",
                                        directory: .library,
                                        customFolder: self.databaseName,
                                        replaceExisting: true)
    }
    
    /** Saves an array of models on the Table file */
    internal func save(table: Table, models: [VCEntityModel]) -> VCOperationResult {
        var entities: [String] = []
        
        // Convert models to entities
        for model in models {
            if let jsonString = model.toJSONString() {
                entities.append(jsonString)
            }
        }
        
        return self.save(table: table, entities: entities as NSArray)
    }
    
    /** Retrieves an array of entities (String format) from a Table */
    internal func retrieve(table: Table) -> [String] {
        if let entities = VCFileManager.readArray(fileName: table.key,
                                                  fileExtension: "plist",
                                                  directory: .library,
                                                  customFolder: self.databaseName) {
            return entities as! [String]
        }
        return []
        
    }
    
    /** Retrieves an array of models from a Table */
    internal func retrieve(table: ParserTable) -> [VCEntityModel] {
        // Loads the Table
        let entities: [String] = self.retrieve(table: table)
        
        // Converts entities to models
        var models: [VCEntityModel] = []
        for entity in entities {
            if let model = table.initializer(entity) {
                models.append(model)
            }
        }
        
        return models
    }
}

/** Simulation of Database models run on RAM for performance improvements.
 Changes made on this Database must be commited, otherwise will be discarded. */
open class VCVirtualDatabase: VCDatabase {
    open let table: ParserTable
    open var models: [VCEntityModel] = []
    
    open var referenceDate: Date?
    
    required public init(table: ParserTable) {
        self.table = table
        super.init()
        self.reset()
    }
    
    /** Commits the models on the local Database */
    open func commit() -> VCOperationResult {
        return sharedDatabase.replace(models: self.models, table: self.table)
    }
    
    /** Resets the models, loading them from the local Database */
    open func reset() -> Void {
        self.models = sharedDatabase.select(table: self.table)
    }
    
    /** Clears the models */
    open func clear() -> Void {
        self.models = []
    }
    
    /// VCDatabase
    
    @available(*, unavailable, message:"Cannot delete a local Table from a Virtual Database")
    open override func delete(table: VCDatabase.Table) -> VCOperationResult {
        return VCOperationResult(success: false, error: nil)
    }
    
    open override func batchInsert(models: [VCEntityModel], table: VCDatabase.Table) -> VCOperationResult {
        self.models.append(contentsOf: models)
        
        return VCOperationResult(success: true, error: nil)
    }
    
    /// VCDatabase - Internal
    
    override func prepareStructure() {
        return
    }
    
    @available(*, unavailable, message:"Virtual Database works directly with models. Try the other save method.")
    override func save(table: VCDatabase.Table, entities: NSArray) -> VCOperationResult {
        return VCOperationResult(success: false, error: nil)
    }
    
    override func save(table: VCDatabase.Table, models: [VCEntityModel]) -> VCOperationResult {
        self.models = models
        
        return VCOperationResult(success: true, error: nil)
    }
    
    @available(*, unavailable, message:"Virtual Database works directly with models. Try the other retrieve method.")
    override func retrieve(table: VCDatabase.Table) -> [String] {
        return []
    }
    
    override func retrieve(table: VCDatabase.ParserTable) -> [VCEntityModel] {
        return self.models
    }
}
