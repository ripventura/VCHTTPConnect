//
//  JSONModel.swift
//  GameCalendar
//
//  Created by Vitor Cesco on 29/05/17.
//  Copyright © 2017 Vitor Cesco. All rights reserved.
//

import UIKit

open class JSONModel: NSObject {

    //Represents this model ID
    public var modelId : Any?
    
    private var propertyKeys : [String:String]
    
    //Initializes the Model with a Data object
    public convenience init(data: Data) {
        do {
            let jsonObject : Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            
            self.init(jsonDict: jsonObject as! [String : Any])
        }
        catch {
            assert(true, "Failed to get JSON from Data")
            self.init()
        }
    }
    //Initializes the Model with a raw JSON dictionary
    public init(jsonDict : [String:Any]) {
        propertyKeys = [:]
        
        super.init()
        
        self.mapModel(jsonDict: jsonDict)
        
        self.initializeFromDict(jsonDict: jsonDict)
    }
    //General initializer
    public override init() {
        propertyKeys = [:]
        
        super.init()
    }
    
    private func initializeFromDict(jsonDict : [String:Any]) -> Void {
        //Loops every property this model has
        for propertyName in self.propertyKeys.keys {
            //Attribute name that should exist in the jsonDict
            let relatedAttributeName = self.propertyKeys[propertyName]!
            
            //If the jsonDict came with this attribute
            if let value = jsonDict[relatedAttributeName] {
                //Update the related property
                self.setValue(value, forKey: propertyName)
            }
        }
    }
    
    // MARK: - Model Mapping
    //All property mapping should be done here. Override this method on each subclass.
    open func mapModel(jsonDict : [String:Any]) -> Void {
        
    }
    //Sets a JSON attribute name for the given property
    public func mapProperty(propertyName: String, toAttribute name: String) -> Void {
        self.propertyKeys[propertyName] = name
    }
    
    
    // MARK: - JSON Generation
    //Generates a JSON Dictionary from this model
    public func jsonDict() -> [String:Any] {
        var dict: [String:Any] = [:]
        
        for propertyName in self.propertyKeys.keys {
            dict[self.propertyKeys[propertyName]!] = self.value(forKey: propertyName)
        }
        
        return dict
    }
}
