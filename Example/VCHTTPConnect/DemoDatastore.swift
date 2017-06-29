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

    open override func datastoreWithConfig() -> VCHTTPDatastore.Config {
        return .init(name: "posts",
                     url: "https://jsonplaceholder.typicode.com",
                     headers: [:])
    }
    
    //Override this if you need to return custom sub-classed models.
    open override func modelFromDict(jsonDict: [String:Any]) -> VCHTTPModel {
        return DemoModel(JSON: jsonDict)!
    }
}
