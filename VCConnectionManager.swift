//
//  VCConnectionManager.swift
//  Alamofire
//
//  Created by Vitor Cesco on 03/03/18.
//

import Foundation
import Alamofire

/** Shared VCConnectionManager. Update it's activeConnection to swap between online and offline mode. */
public let sharedConnectionManager: VCConnectionManager = VCConnectionManager()

/** Responsible for managing the active ConnectionState used on Datastore loading. */
open class VCConnectionManager {
    public enum ConnectionState {
        case online, offline
    }
    
    public enum ConnectionNotification: String {
        case stateChanged = "VCConnectionManagerStateChangedNotification"
    }
    
    open var state: ConnectionState = .online {
        didSet {
            NotificationCenter.default.post(name: Notification.Name.init(rawValue: ConnectionNotification.stateChanged.rawValue), object: nil, userInfo: nil)
        }
    }
    
    public init() {
        
    }
    
    /** Verifies if the device has Internet Connection */
    open func checkConnectivity(completion: @escaping ((Bool) -> Void)) -> Void {
        if NetworkReachabilityManager()!.isReachable {
            let connector = VCHTTPConnect(url: "https://www.google.com",
                                          parameters: [:],
                                          headers: ["Cache-Control":"no-cache"])
            connector.get(path: "", handler: {_, response in
                completion(response.statusCode == 200)
            })
        }
        else {
            completion(false)
        }
    }
}
