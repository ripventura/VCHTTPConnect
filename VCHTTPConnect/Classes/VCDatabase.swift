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
    
    init() {
        self.prepareStructure()
    }
    
    /** Inserts the model on the Database */
    open func insert(model: VCEntityModel, replace: Bool = true) -> VCOperationResult {
        _ = VCFileManager.createFolderInDirectory(directory: .library,
                                                  folderName: self.entityFolderName(model: model))
        
        if let modelId = model.modelId {
            return VCFileManager.writeJSON(json: model.toJSON(),
                                           fileName: modelId,
                                           fileExtension: "json",
                                           directory: .library,
                                           customFolder: self.entityFolderName(model: model),
                                           replaceExisting: replace)
        }
        
        return VCOperationResult(success: false, error: nil)
    }
    
    /** Selects models from the Database, based on the class of the reference model */
    open func select(referenceModel: VCEntityModel,
                     instantiate: (([String:Any]) -> VCEntityModel?),
                     filter: ((VCEntityModel) -> Bool)) -> [VCEntityModel] {
        var entities: [VCEntityModel] = []
        
        // Lists all the files on this Database folder
        for fileName in VCFileManager.listFilesInDirectory(directory: .library, customFolder: self.entityFolderName(model: referenceModel)) {
            // If the file is JSON
            if let jsonEntity = VCFileManager.readJSON(fileName: fileName as! String,
                                                       fileExtension: "",
                                                       directory: .library,
                                                       customFolder: self.entityFolderName(model: referenceModel)) as? [String:Any] {
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
    
    private func entityFolderName(model: VCEntityModel) -> String {
        return self.databaseFolderName() + "/" + String(describing: model)
    }
}
