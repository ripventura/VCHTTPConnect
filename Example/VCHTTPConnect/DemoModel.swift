//
//  DemoModel.swift
//  VCHTTPConnect
//
//  Created by Vitor Cesco on 29/05/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import VCHTTPConnect

class DemoModel: HTTPModel {
    var title: String?
    var body: String?
    
    //All property mapping should be done here. Override this method on each subclass.
    override func mapModel(jsonDict: [String : Any]) -> Void {
        
        //propertyName = this object property name
        //attribute = API attribute name (coming from the JSON)
        self.mapProperty(propertyName: "modelId", toAttribute: "id")
        self.mapProperty(propertyName: "title", toAttribute: "title")
        self.mapProperty(propertyName: "body", toAttribute: "body")
    }

    //Connector should be initialized here. Override this method on each subclass.
    public override func initializeConnector() -> Void {
        self.connector = VCHTTPConnect(url: "https://jsonplaceholder.typicode.com/posts")
    }
}
