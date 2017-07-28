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
        return self.save(table: table, models: models)
    }
    
    // MARK: - SELECT
    
    /** Selects models from a given Table. */
    open func select(table: ParserTable,
                     filter: ((VCEntityModel) -> Bool)) -> [VCEntityModel] {
        // Loads the Table models
        var models: [VCEntityModel] = self.retrieve(table: table)
        
        // Filters all the models
        models = models.filter({model in
            return filter(model)
        })
        
        return models
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
    
    private func prepareStructure() -> Void {
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
