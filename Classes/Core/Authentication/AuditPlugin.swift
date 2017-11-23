//
//  AuditPlugin.swift
//  MPOLKit
//
//  Created by Valery Shorinov on 19/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

open class AuditPlugin: PluginType {
    
    static let auditSessionIdKey = "X-Session-ID"
    static let auditDeviceIdKey = "X-Device-ID"
    static let auditTransactionIdKey = "X-Transaction-ID"
    
    public init() {
        
    }
    
    open func adapt(_ urlRequest: URLRequest) -> Promise<URLRequest> {
        var adaptedRequest = urlRequest
        
        let session = UserSession.current
        
        adaptedRequest.addValue(session.sessionID, forHTTPHeaderField: AuditPlugin.auditSessionIdKey)
        
        // Temporary untill we have a Device ID from MDM
        adaptedRequest.addValue(UIDevice.current.identifierForVendor!.uuidString, forHTTPHeaderField: AuditPlugin.auditDeviceIdKey)
        // Temporary until we decide how generate and store transaction IDs
        adaptedRequest.addValue("TestID", forHTTPHeaderField: AuditPlugin.auditTransactionIdKey)

        return Promise(value: adaptedRequest)
    }
    
}
