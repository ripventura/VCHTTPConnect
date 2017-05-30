//
//  DemoModel.swift
//  VCHTTPConnect
//
//  Created by Vitor Cesco on 29/05/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import VCHTTPConnect
import ObjectMapper

class DemoModel: VCHTTPModel {
    var title: String?
    var body: String?
    
    // Mappable
    override func mapping(map: Map) {
        super.mapping(map: map)
        self.title <- map["title"]
        self.body <- map["body"]
    }

    //Connector should be initialized here. Override this method on each subclass.
    public override func initializeConnector() -> Void {
        self.connector = VCHTTPConnect(url: "https://jsonplaceholder.typicode.com/posts")
    }
}
