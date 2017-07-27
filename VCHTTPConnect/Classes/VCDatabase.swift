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
    public struct Table {
        /** The name of the Table */
        public let name: String
        /** An optional key used to differ the content of this Table to the content of other Tables with the same Name */
        public var key: String?
        
        public init(name: String, key: String?) {
            self.name = name
            self.key = key
        }
    }
    
    public init() {
        self.prepareStructure()
    }
    
    /** Inserts a model on a given Table. */
    open func insert(model: VCEntityModel, table: Table, replace: Bool = true) -> VCOperationResult {
        _ = VCFileManager.createFolderInDirectory(directory: .library,
                                                  folderName: self.entityFolderName(table: table))
        
        if let modelId = model.modelId {
            return VCFileManager.writeJSON(json: model.toJSON(),
                                           fileName: modelId,
                                           fileExtension: "json",
                                           directory: .library,
                                           customFolder: self.entityFolderName(table: table),
                                           replaceExisting: replace)
        }
        
        return VCOperationResult(success: false, error: nil)
    }
    
    /** Batch Inserts an Array of models on a given Table. */
    open func batchInsert(models: [VCEntityModel], table: Table, replace: Bool = true) -> [VCOperationResult] {
        var results: [VCOperationResult] = []
        
        for model in models {
            results.append(self.insert(model: model, table: table, replace: replace))
        }
        
        return results
    }
    
    /** Selects models from a given Table. */
    open func select(table: Table,
                     instantiate: (([String:Any]) -> VCEntityModel?),
                     filter: ((VCEntityModel) -> Bool)) -> [VCEntityModel] {
        var entities: [VCEntityModel] = []
        
        // Lists all the files on this Database folder
        for fileName in VCFileManager.listFilesInDirectory(directory: .library, customFolder: self.entityFolderName(table: table)) {
            // If the file is JSON
            if let jsonEntity = VCFileManager.readJSON(fileName: fileName as! String,
                                                       fileExtension: "",
                                                       directory: .library,
                                                       customFolder: self.entityFolderName(table: table)) as? [String:Any] {
                // If the instatiation was successfull
                if let entity = instantiate(jsonEntity) {
                    // Appends the entity
                    entities.append(entity)
                }
            }
        }
        
        // Filters all the entities
        entities = entities.filter({model in
            return filter(model)
        })
        
        return entities
    }
    
    // MARK: - Internal
    
    private func prepareStructure() -> Void {
        _ = VCFileManager.createFolderInDirectory(directory: .library,
                                                  folderName: self.databaseFolderName())
    }
    
    private func databaseFolderName() -> String {
        return "VCDatabase"
    }
    
    private func entityFolderName(table: Table) -> String {
        return self.databaseFolderName() + "/" + table.name + (table.key ?? "")
    }
}
