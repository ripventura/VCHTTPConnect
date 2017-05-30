//
//  DemoDatastore.swift
//  VCHTTPConnect
//
//  Created by Vitor Cesco on 30/05/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import VCHTTPConnect

class DemoDatastore: VCHTTPDatastore {

    //Override this if you sub-class to a custom datastore.
    open override func datastoreName() -> String {
        return "posts"
    }
    //Override this if you sub-class to a custom datastore.
    open override func datastoreURL() -> String {
        return "https://jsonplaceholder.typicode.com"
    }
    //Override this if you need to return custom sub-classed models.
    open override func modelFromDict(jsonDict: [String:Any]) -> VCHTTPModel {
        return DemoModel(JSON: jsonDict)!
    }
}
