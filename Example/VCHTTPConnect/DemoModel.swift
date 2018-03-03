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

class DemoModel: VCEntityModel {
    var title: String?
    var body: String?
    
    // Mappable
    override func mapping(map: Map) {
        super.mapping(map: map)
        self.title <- map["title"]
        
        self.body <- map["body"]
    }
}
