//
//  VCGraphQLModel.swift
//  Pods
//
//  Created by Vitor Cesco on 29/06/17.
//
//

import Foundation
import ObjectMapper

open class VCGraphQLModel: VCEntityModel {
    open override func initializeConnector() -> Void {
        self.connector = VCHTTPConnect(url: sharedGraphQLConfig.host,
                                       parameters: [:],
                                       headers: sharedGraphQLConfig.headers)
    }
}
